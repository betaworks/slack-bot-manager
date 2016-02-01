module SlackBotManager
  class Client
    include Commands
    include Errors
    include Logger

    attr_accessor :commands, :connection, :id, :token, :status
    attr_accessor(*Config::CLIENT_ATTRIBUTES)

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

      # Assign commands
      methods.each do |n|
        # Require methods to include on_*
        next unless n.match(/^on_/) && respond_to?(n)
        assign_event(n.to_s.gsub(/^on_/, ''), n)
      end

      connect
    end

    # Pull info from slack-ruby-client gem
    [:url, :team, :self, :users, :channels, :groups, :ims, :bots].each do |attr|
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

    def disconnect(reason = :disconnected)
      connection && connection.stop!
    rescue => err
      handle_error(err)
    ensure
      @status = reason if @status == :connected
      remove_instance_variable(:@connection) if @connection
    end

    def connected?
      connection && connection.started?
    end

    def disconnected?
      !connected?
    end

    protected

    def send_message(channel, text, *args)
      options = args.extract_options!
      # TODO : HANDLE CASES WHERE NEED TO POST ATTACHMENTS, SEND DMs, ETC
      options[:channel] = channel
      options[:text] = text
      connection.message(options)
    end

    def assign_event(evt, evt_name)
      connection.on(evt) do |data|
        begin
          send(evt_name, data) if respond_to?(evt_name)
        rescue => err
          handle_error(err)
        end
      end
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
