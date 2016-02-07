module SlackBotManager
  class Manager
    include Tokens
    include Connection
    include Errors
    include Logger

    attr_accessor :connections, :storage
    attr_accessor(*Config::MANAGER_ATTRIBUTES)

    def initialize(*args)
      options = args.extract_options!

      # Storage of connection keys
      @connections = {}

      # Load config options
      SlackBotManager::Config::MANAGER_ATTRIBUTES.each do |key|
        send("#{key}=", options[key] || SlackBotManager.config.send(key))
      end

      # Set token storage method
      @storage = storage_method.new(storage_options)
    end

    # Include config helpers
    class << self
      def configure
        block_given? ? yield(config) : config
      end

      def config
        Config
      end
    end
  end
end
