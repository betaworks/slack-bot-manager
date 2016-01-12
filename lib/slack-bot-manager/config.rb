module SlackBotManager
  module Config

    extend self

    ATTRIBUTES = [
      :tokens_key,
      :teams_key,
      :check_interval,
      :redis,
      :logger,
      :log_level,
      :verbose
    ]

    attr_accessor(*Config::ATTRIBUTES)

    def reset
      self.tokens_key = 'tokens:statuses'
      self.teams_key = 'tokens:teams'
      self.check_interval = 5 # seconds
      self.redis = Redis.new
      self.logger = defined?(Rails) ? Rails.logger : ::Logger.new(STDOUT)
      self.log_level = ::Logger::INFO
      self.logger.formatter = SlackBotManager::Logger::Formatter.new
      self.verbose = false
    end

    def verbose=(val)
      @verbose = val
      self.log_level = val ? ::Logger::DEBUG : ::Logger::INFO
    end

    def log_level=(level)
      self.logger.level = level
    end

    def log_formatter=(formatter)
      self.logger.formatter = formatter
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
