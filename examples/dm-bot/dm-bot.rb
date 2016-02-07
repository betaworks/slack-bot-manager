#
# dm-bot.rb
# -------------------------------------------------
#
# Example created for slack-bot-manager by @gleuch.
# License: MIT
# https://github.com/betaworks/slack-bot-manager
#
# -------------------------------------------------
#
# To get started:
#   1. Run: `mv tokens.yml.sample tokens.yml`
#   2. Add your token(s) to tokens.yml
#   3. Run: `ruby dm-bot.rb`
#


# Require necessary gems
require 'yaml'

require 'rubygems'
require 'bundler/setup'
Bundler.require


# Extend commands to handle what we want done
module SlackBotManager
  module Commands

    def on_message(data)
      # Only support DMs with bot
      return unless data['channel'].start_with?('D')

      # Get user info
      user_key = ['users', self.id, data['user']].join(':')
      storage.connection.del user_key
      unless storage.connection.exists user_key
        # Get user info from Slack
        user_info = self.connection.web_client.users_info(user: data['user'])['user']

        # Store the basics into redis for quicker lookups
        storage.connection.hmset user_key, *{ id: user_info['id'], name: user_info['name'], real_name: user_info['real_name'], is_bot: user_info['is_bot'] ? 1 : 0 }.flatten
        # Expire this redis key weekly so that we do regular updates
        storage.connection.expire user_key, 604800 # 1 week in seconds
      end
      user_info = storage.connection.hgetall user_key

      return if [1,'1','true'].include?(user_info['is_bot'])

      # Get IM info, send hello message if first time
      im_key = ['ims', self.id, data['channel']].join(':')
      storage.connection.del im_key
      unless storage.connection.exists im_key
        storage.connection.hmset im_key, *{ id: data['channel'], user: user_info['id'], started: Time.now.to_i, messages_sent: 0, messages_received: 0 }.flatten
        send_message(data['channel'], "Hello there <@#{user_info['id']}>! I'm happy to listen to what you have to say. :simple_smile:")
        storage.connection.hincrby im_key, 'messages_sent', 1
      end
      im_info = storage.connection.hgetall im_key

      # Increment message count
      storage.connection.hincrby im_key, 'messages_received', 1

      # Parse message contents
      msg = 'If i was smarter, I would respond with something witty.'

      send_message(data['channel'], msg)
      storage.connection.hincrby im_key, 'messages_sent', 1
    end

  end
end

# Initialize SlackBotManager
@bot_manager = SlackBotManager::Manager.new

# Load tokens from YAML list
tokens = YAML.load_file('tokens.yml')['tokens']
@bot_manager.add_token(*tokens) # Add tokens

# Close connections on sig interrupts
['INT','TERM'].each do |s|
  Signal.trap(s) do
    @bot_manager.stop
    @bot_manager.clear_tokens
    exit
  end
end

# Start the RTM connections
@bot_manager.start

# Lets monitor the connection
@bot_manager.monitor
