module SlackBotManager

  class ConnectionClosed < StandardError; end
  class ConnectionRateLimited < StandardError; end
  class InvalidToken < StandardError; end
  class TokenAlreadyConnected < StandardError; end
  class TokenNotConnected < StandardError; end
  class TokenRevoked < StandardError; end


  module Errors

    # Mapping of error classes to type
    CLASS_ERROR_TYPES = {
      token_revoked: [
        SlackBotManager::InvalidToken, 
        SlackBotManager::TokenRevoked
      ],
      rate_limited: [
        SlackBotManager::ConnectionRateLimited
      ],
      closed: [
        SlackBotManager::ConnectionClosed,
        Slack::RealTime::Client::ClientNotStartedError
      ],
    }

    # Regexp mapping of error keywords to type
    STRING_ERROR_TYPES = {
      token_revoked: /token_revoked|account_inactive|invalid_auth/i,
      rate_limited: /rate_limit|status 429/i,
      closed: /closed/i,
    }

    def determine_error_type(err)
      # Check known error types, unless string
      CLASS_ERROR_TYPES.each{|k,v| return k if v.include?(err) } unless err.is_a?(String)

      # Check string matches, as we might get code responses or capture something inside it
      STRING_ERROR_TYPES.each{|k,v| return k if v.match(err.to_s) }

      :error
    end

    def on_error(err,data=nil)
      error(err)
    end

  end
end
