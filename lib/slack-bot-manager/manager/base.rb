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
      @storage = storage_class.new(storage_method)
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

    protected

    def storage_class
      # TODO : is there better way to do this?
      "SlackBotManager::Storage::#{storage_method.class}".constantize
    end

  end
end
