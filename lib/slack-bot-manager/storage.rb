module SlackBotManager
  module Storage
    autoload :Redis, 'slack-bot-manager/storage/redis'
    autoload :Dalli, 'slack-bot-manager/storage/dalli'
  end
end
