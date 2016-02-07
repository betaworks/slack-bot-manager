module SlackBotManager
  module Tokens
    # Add token(s) to be connected
    def add_token(*tokens)
      tokens.map do |token|
        begin
          team_info = check_token_status(token)

          # Add to token list
          storage.set(tokens_key, team_info['team_id'], token)
          true
        rescue => err
          on_error(err)
          false
        end
      end
    end

    # Remove token(s) and connection(s)
    def remove_token(*tokens)
      tokens.map do |token|
        begin
          id = get_id_from_token(token) # As token should be in list
          fail SlackBotManager::InvalidToken if !id || id.empty?

          # Delete from token and connections list
          storage.delete(tokens_key, id)
          storage.delete(teams_key, id)
          true
        rescue => err
          on_error(err)
          false
        end
      end
    end

    # Remove all tokens
    def clear_tokens
      remove_token(*storage.get_all(tokens_key).values)
    rescue
      nil
    end

    # Restart token connection(s)
    def update_token(*tokens)
      tokens.map do |token|
        begin
          id = get_id_from_token(token) # As token should be in list
          fail SlackBotManager::InvalidToken if !id || id.empty?

          # Issue reset command
          storage.set(teams_key, id, 'restart')
          true
        rescue => err
          on_error(err)
          false
        end
      end
    end

    # Check token connection(s)
    def check_token(*tokens)
      rtm_keys = storage.get_all(teams_key)

      tokens.map do |token|
        begin
          team_info = check_token_status(token)
          key_info = rtm_keys[team_info['team_id']] || 'not_connected'
          info("Team #{team_info['team_id']} :: #{key_info}")
          true
        rescue => err
          on_error(err)
          false
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
      storage.get_all(tokens_key).each { |id, t| return id if t == token }
      false
    end
  end
end
