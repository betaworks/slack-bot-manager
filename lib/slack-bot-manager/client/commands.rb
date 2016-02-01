module SlackBotManager
  module Commands
    # Handle when connection gets closed
    def on_close(data, *args)
      options = args.extract_options!
      options[:code] ||= (data && data.code) || '1000'

      disconnect
      fail SlackBotManager::ConnectionRateLimited if %w(1008 429).include?(options[:code].to_s)
    end

    # Handle rate limit errors coming from web API
    def on_revoke(*)
      disconnect(:token_revoked)
      fail SlackBotManager::TokenRevoked
    end

    # Handle rate limit errors coming from web API
    def on_rate_limit(*)
      disconnect(:rate_limited)
      fail SlackBotManager::ConnectionRateLimited
    end
  end
end
