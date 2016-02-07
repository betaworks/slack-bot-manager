module SlackBotManager
  module Storage
    autoload :Redis, 'slack-bot-manager/manager/storage/redis'
    autoload :Dalli, 'slack-bot-manager/manager/storage/dalli'
  end
end
