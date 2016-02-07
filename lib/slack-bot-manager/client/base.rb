module SlackBotManager
  class Client
    include Commands
    include Errors
    include Logger

    attr_accessor :commands, :connection, :id, :token, :status
    attr_accessor(*Config::CLIENT_ATTRIBUTES)
    attr_accessor(*Config::READONLY_ATTRIBUTES)

    def initialize(token, *args)
      options = args.extract_options!

      # Option values
      @token = token
      @id = options[:id]
      @status = :disconnected

      # Setup client and assign commands
      @connection = Slack::RealTime::Client.new(token: @token)

      # Load config options
      SlackBotManager::Config::CLIENT_ATTRIBUTES.each do |key|
        send("#{key}=", options[key] || SlackBotManager.config.send(key))
      end
      self.storage = SlackBotManager.config.send(:storage)

      # Assign commands
      methods.each do |n|
        # Require methods to include on_*
        next unless n.match(/^on_/) && respond_to?(n)
        assign_event(n.to_s.gsub(/^on_/, ''), n)
      end
    end

    # Pull info from slack-ruby-client gem
    SlackBotManager::Config::RTM_CLIENT_METHODS.each do |attr|
      define_method "client_#{attr}" do
        connection.send(attr) if connected?
      end
    end

    def connect
      connection.start_async
      @id ||= client_team['id']
      @status = :connected
    rescue => err
      handle_error(err)
    end

    def disconnect(reason = nil)
      connection && connection.stop!
    rescue => err
      handle_error(err)
    ensure
      @status = reason || :disconnected # if @status == :connected
      remove_instance_variable(:@connection) if @connection
    end

    def connected?
      connection && connection.started?
    end

    def disconnected?
      !connected?
    end

    def on(evt, &block)
      self.class.send(:define_method, "on_#{evt}", &block)
      assign_event(evt, "on_#{evt}")
    end

    def off(evt)
      self.class.send(:remove_method, "on_#{evt}")
      unassign_event(evt)
    end

    def message(channel, text=nil, *args)
      options = args.extract_options!
      if options.keys.length > 0
        connection.web_client.chat_postMessage(options.merge(channel: channel, text: text))
      else
        connection.message(options.merge(channel: channel, text: text))
      end
    end
    alias_method :send_message, :message

    def typing(channel, *args)
      options = args.extract_options!
      connection.typing(options.merge(channel: channel))
    end

    def ping(*args)
      options = args.extract_options!
      connection.ping(options)
    end

    protected

    def assign_event(evt, evt_name)
      connection.on(evt) do |data|
        begin
          send(evt_name, data) if respond_to?(evt_name)
        rescue => err
          handle_error(err)
        end
      end
    end

    def unassign_event(evt)
      connection.off(evt) if connection
    end

    # Handle different error cases
    def handle_error(err, data = nil)
      case determine_error_type(err)
      when :token_revoked
        on_revoke(data)
      when :rate_limited
        on_rate_limit(data)
      when :closed
        on_close(data)
      else
        on_error(err, data)
      end
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
