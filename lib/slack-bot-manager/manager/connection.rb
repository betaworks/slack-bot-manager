module SlackBotManager
  module Connection

    # Monitor our connections, while connections is {...}
    def monitor
      while connections
        sleep 1 # Pause momentarily

        # On occasion, check our connection statuses
        next unless Time.now.to_i % check_interval == 0

        # Get tokens and connection statuses
        tokens_status = redis.hgetall(tokens_key)
        rtm_status = redis.hgetall(teams_key)

        # Manage connections
        connections.each do |cid, conn|
          id, _s = cid.split(':')

          # Remove/continue if connection is/will close or no longer connected
          if !conn
            warning("Removing: #{id} (Reason: rtm_not_connection)")
            destroy(cid: cid)

          elsif !conn.connected?
            warning("Removing: #{conn.id} (Reason: #{conn.status})")
            to_remove = ['token_revoked'].include?((conn.status || '').to_s)
            destroy(cid: cid, remove_token: to_remove)

          # Team is no longer valid, remove
          elsif tokens_status[conn.id].nil? || tokens_status[conn.id].empty?
            warning("Removing: #{conn.id} (Reason: token_missing)")
            destroy(cid: cid, remove_token: true)

          elsif rtm_status[conn.id] == 'destroy'
            warning("Removing: #{conn.id} (Reason: token_destroy)")
            destroy(cid: cid)

          # Kill connection if token has changed, will re-create next block below
          elsif tokens_status[conn.id] != conn.token
            warning("Removing: #{conn.id} (Reason: new_token)")
            destroy(cid: cid)

          # Connection should be re-created unless it is active, will update next block below
          elsif rtm_status[conn.id] != 'active'
            warning("Restarting: #{conn.id} (Reason: #{rtm_status[conn.id] || '(unknown)'})")
            destroy(cid: cid)
            redis.hset(tokens_key, conn.id, tokens_status[conn.id])
          end
        end

        # Give pause before any reconnects, as destroy methods might still be processing in their threads
        sleep 1

        # Check for new tokens / reconnections (reload keys since we might modify if bad). Kill and recreate
        tokens_status = redis.hgetall(tokens_key)
        rtm_status = redis.hgetall(teams_key)
        tokens_diff = (tokens_status.keys - rtm_status.keys) + (rtm_status.keys - tokens_status.keys)

        unless tokens_diff.empty?
          tokens_diff.uniq.each do |id|
            warning("Starting: #{id}")
            destroy(id: id)
            create(id, tokens_status[id])
          end
        end

        info("Active Connections: [#{connections.count}]")
      end
    end

    # Create websocket connections for active tokens
    def start
      # Clear RTM connections
      redis.del(teams_key)

      # Start a new connection for each team
      redis.hgetall(tokens_key).each do |id, token|
        create(id, token)
      end
    end

    # Remove all connections from app, will disconnect in monitor loop
    def stop
      # Thread wrapped to ensure no lock issues on shutdown
      thr = Thread.new {
        conns = redis.hgetall(teams_key)
        redis.pipelined do
          conns.each { |k, _| redis.hset(teams_key, k, 'destroy') }
        end
        info('Stopped.')
      }
      thr.join
    end

    # Issue restart status on all RTM connections, will re-connect in monitor loop
    def restart
      conns = redis.hgetall(teams_key)
      redis.pipelined do
        conns.each { |k, _| redis.hset(teams_key, k, 'restart') }
      end
    end

    # Get status of current connections
    def status
      info("Active connections: [#{redis.hgetall(teams_key).count}]")
    end


    protected

    # Find the connection based on id and has active connection
    def find_connection(id)
      connections.each do |_, conn|
        return (conn.connected? ? conn : false) if conn && conn.id == id
      end
      false
    end

    # Create new connection if not exist
    def create(id, token)
      fail SlackBotManager::TokenAlreadyConnected if find_connection(id)

      # Create connection
      conn = SlackBotManager::Client.new(id, token)

      # Add to connections using a uniq token, as we might have connection closing and opening with same id
      if conn
        cid = [id, Time.now.to_i].join(':')
        connections[cid] = conn
        info("Connected: #{id} (Connection: #{cid})")
        redis.hset(teams_key, id, 'active')
      end
    rescue => err
      on_error(err)
    end

    # Disconnect from a RTM connection
    def destroy(*args)
      options = args.extract_options!

      # Get connection or search for connection with cid
      if options[:cid]
        conn, cid = connections[options[:cid]], options[:cid]
      elsif options[:id]
        conn, cid = find_connection(options[:id])
      end
      return false unless conn && cid

      # Kill connection, remove from connection keys, and delete from connections list
      begin
        thr = Thread.new {
          redis.hdel(teams_key, conn.id) rescue nil
          redis.hdel(tokens_key, conn.id) rescue nil if options[:remove_token]
        }
        thr.join
        connections.delete(cid)
      rescue
        nil
      end
    rescue => err
      on_error(err)
    end

  end
end
