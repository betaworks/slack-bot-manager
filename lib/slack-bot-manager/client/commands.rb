module SlackBotManager
  module Commands

    # Handle when connection gets closed
    def on_close(data, *args)
      options = args.extract_options!
      options[:code] ||= (data && data.code) || '1000'

      disconnect
      raise SlackBotManager::ConnectionRateLimited if ['1008','429'].include?(options[:code].to_s)
    end

    # Handle rate limit errors coming from web API
    def on_revoke(data)
      disconnect(:token_revoked)
      raise SlackBotManager::TokenRevoked
    end

    # Handle rate limit errors coming from web API
    def on_rate_limit(data)
      disconnect(:rate_limited)
      raise SlackBotManager::ConnectionRateLimited
    end

  end
end
