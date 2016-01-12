module SlackBotManager
  class Client

    include Commands
    include Errors
    include Logger

    attr_accessor :commands, :connection, :id, :token, :status
    attr_accessor :logger


    def initialize(id, token, *args)
      opts = args.extract_options!
      @id, @token, @events, @status = id, token, opts[:events] || {}, :disconnected

      # Setup client and assign commands
      @connection = Slack::RealTime::Client.new(token: @token)

      # Load just logger config
      [:logger].each do |key|
        send("#{key}=", opts[key] || SlackBotManager.config.send(key))
      end

      # Assign commands
      self.methods.each do |n|
        # Require methods to include on_*
        next unless n.match(/^on_/) && self.respond_to?(n)
        assign_event(n.to_s.gsub(/^on_/, ''), n)
      end

      connect
    end

    def connect
      connection.start_async
      @status = :connected
    rescue => err
      handle_error(err)
    end

    def disconnect(reason=:disconnected)
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

    def send_message(text, *args)
      opts = args.extract_options!
      # TODO : HANDLE CASES WHERE NEED TO POST ATTACHMENTS, SEND DMs, ETC
      opts[:text] = text
      connection.message(opts)
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
    def handle_error(err, data=nil)
      case determine_error_type(err)
        when :token_revoked;  on_revoke(data)
        when :rate_limited;   on_rate_limit(data)
        when :closed;         on_close(data)
        else;                 on_error(err, data)
      end
    end

  end
end
