module SlackBotManager
  module Config
    extend self

    READONLY_ATTRIBUTES = [
      :storage
    ].freeze

    GLOBAL_ATTRIBUTES = [
      :storage_options,
      :storage_adapter,
      :logger,
      :log_level,
      :verbose,
    ].freeze

    MANAGER_ATTRIBUTES = ([
      :tokens_key,
      :teams_key,
      :check_interval,
    ] + GLOBAL_ATTRIBUTES).freeze

    CLIENT_ATTRIBUTES = ([
      # n/a
    ] + GLOBAL_ATTRIBUTES).freeze

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

    attr_accessor :storage
    attr_accessor(*Config::MANAGER_ATTRIBUTES)
    attr_accessor(*Config::CLIENT_ATTRIBUTES)
    attr_accessor(*Config::READONLY_ATTRIBUTES)
    attr_accessor(*Config::WEB_CLIENT_ATTRIBUTES)
    attr_accessor(*Config::RTM_CLIENT_ATTRIBUTES)

    def reset
      # Slack web and realtime config options
      Slack::Web::Config.reset
      Slack::RealTime::Config.reset

      # Token storage options
      self.storage = nil
      self.storage_options = {}
      self.storage_adapter = method(:detect_storage_adapter)

      # Token options
      self.tokens_key = 'tokens:statuses'
      self.teams_key = 'tokens:teams'

      # Logger options
      self.logger = defined?(Rails) ? Rails.logger : ::Logger.new(STDOUT)
      self.log_level = ::Logger::INFO
      self.logger.formatter = SlackBotManager::Logger::Formatter.new
      self.verbose = false

      # Connection options
      self.check_interval = 5 # seconds
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

    def storage_adapter
      (val = @storage_adapter).respond_to?(:call) ? val.call : val
    end

    def storage_adapter=(val)
      # return if self.storage.present? && val == @storage_adapter
      @storage_adapter = val
      self.storage = @storage_adapter.present? ? storage_adapter.new(self.storage_options) : nil
    end

    def storage_options=(val)
      # return if val == @storage_options
      @storage_options = val
      self.storage = nil
      self.storage_adapter = @storage_adapter # Re-initialize
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

    def detect_storage_adapter
      [:Redis, :Dalli].each do |storage_adapter|
        begin
          return SlackBotManager::Storage.const_get(storage_adapter)
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
