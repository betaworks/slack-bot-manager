# Initialize
require 'dotenv'
Dotenv.load

require 'rubygems'
require 'bundler/setup'

require './slack.rb'

APP_ENV = ENV['APP_ENV'] if !defined?(APP_ENV) && ENV['APP_ENV']
APP_ENV = 'development' if !defined?(APP_ENV)

Bundler.require(:default, APP_ENV.to_sym)

# Create bot manager
botmanager = SlackBotManager::Manager.new

# Add Slack token
botmanager.add_token(ENV['SLACK_TOKEN'])

# Start manager
botmanager.start
botmanager.monitor
