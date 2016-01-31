module SlackBotManager
  module Tokens

    # Add token(s) to be connected
    def add_token(*tokens)
      tokens.each do |token|
        begin
          team_info = check_token_status(token)

          # Add to token list
          redis.hset(tokens_key, team_info['team_id'], token)
        rescue => err
          on_error(err)
        end
      end
    end

    # Remove token(s) and connection(s)
    def remove_token(*tokens)
      tokens.each do |token|
        begin
          id = get_id_from_token(token) # As token should be in list
          fail SlackBotManager::InvalidToken if !id || id.empty?

          # Delete from token and connections list
          redis.hdel(tokens_key, id)
          redis.hdel(teams_key, id)
        rescue => err
          on_error(err)
        end
      end
    end

    # Remove all tokens
    def clear_tokens
      remove_token(*redis.hgetall(tokens_key).values)
    rescue
      nil
    end

    # Restart token connection(s)
    def update_token(*tokens)
      tokens.each do |token|
        begin
          id = get_id_from_token(token) # As token should be in list
          fail SlackBotManager::InvalidToken if !id || id.empty?

          # Issue reset command
          redis.hset(teams_key, id, 'restart')
        rescue => err
          on_error(err)
        end
      end
    end

    # Check token connection(s)
    def check_token(*tokens)
      rtm_keys = redis.hgetall(teams_key)

      tokens.each do |token|
        begin
          team_info = check_token_status(token)

          info("Team #{team_info['team_id']} :: #{rtm_keys[ team_info['team_id'] ] || 'not_connected'}")
        rescue => err
          on_error(err)
        end
      end
    end

    protected

    # Get team id from Slack. (also test if token is valid)
    def check_token_status(token)
      info = Slack::Web::Client.new(token: token).auth_test
      fail SlackBotManager::InvalidToken unless info && info['ok']
      info
    end

    # Given a token, get id from tokens list
    def get_id_from_token(token)
      redis.hgetall(tokens_key).each { |id, t| return id if t == token }
      false
    end

  end
end
