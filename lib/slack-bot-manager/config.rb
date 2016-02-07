module SlackBotManager
  module Config
    extend self

    MANAGER_ATTRIBUTES = [
      :tokens_key,
      :teams_key,
      :check_interval,
      :storage_method,
      :storage_options,
      :logger,
      :log_level,
      :verbose
    ].freeze

    CLIENT_ATTRIBUTES = [
      :logger,
      :log_level,
      :verbose
    ].freeze

    WEB_CLIENT_ATTRIBUTES = [
      :user_agent,
      :proxy,
      :ca_path,
      :ca_file,
      :endpoint
    ].freeze

    RTM_CLIENT_ATTRIBUTES = [
      :websocket_ping,
      :websocket_proxy
    ].freeze

    RTM_CLIENT_METHODS = [
      :url,
      :team,
      :self,
      :users,
      :channels,
      :groups,
      :ims,
      :bots
    ].freeze

    attr_accessor(*Config::MANAGER_ATTRIBUTES)
    attr_accessor(*Config::CLIENT_ATTRIBUTES)
    attr_accessor(*Config::WEB_CLIENT_ATTRIBUTES)
    attr_accessor(*Config::RTM_CLIENT_ATTRIBUTES)

    def reset
      # Slack web and realtime config options
      Slack::Web::Config.reset
      Slack::RealTime::Config.reset

      self.tokens_key = 'tokens:statuses'
      self.teams_key = 'tokens:teams'
      self.check_interval = 5 # seconds
      self.storage_method = method(:detect_storage_method)
      self.storage_options = {}
      self.logger = defined?(Rails) ? Rails.logger : ::Logger.new(STDOUT)
      self.log_level = ::Logger::INFO
      self.logger.formatter = SlackBotManager::Logger::Formatter.new
      self.verbose = false
      self.user_agent = "Slack Bot Manager/#{SlackBotManager::VERSION} <https://github.com/betaworks/slack-bot-manager>"
    end

    # Slack Web Client config
    Config::WEB_CLIENT_ATTRIBUTES.each do |name|
      define_method "#{name}=" do |val|
        Slack::Web.configure do |config|
          config.send("#{name}=", val)
        end
      end
    end

    # Slack RealTime Client config
    Config::RTM_CLIENT_ATTRIBUTES.each do |name|
      define_method "#{name}=" do |val|
        Slack::Web.configure do |config|
          config.send("#{name}=", val)
        end
      end
    end

    def storage_method
      (val = @storage_method).respond_to?(:call) ? val.call : val
    end

    def verbose=(val)
      @verbose = val
      self.log_level = val ? ::Logger::DEBUG : ::Logger::INFO
    end

    def logger=(log)
      @logger = log

      # Also define Slack Web client logger
      Slack::Web.configure do |config|
        config.logger = @logger
      end
    end

    def log_level=(level)
      self.logger.level = level
    end

    def log_formatter=(formatter)
      self.logger.formatter = formatter
    end

    private

    def detect_storage_method
      [:Redis, :Dalli].each do |storage_method|
        begin
          return SlackBotManager::Storage.const_get(storage_method)
        rescue LoadError, NameError
          false
        end
      end

      fail NoStorageMethod, 'Missing storage method. Add redis or dalli to your Gemfile.'
    end
  end

  class << self
    def configure
      block_given? ? yield(Config) : Config
    end

    def config
      Config
    end
  end
end

SlackBotManager::Config.reset
