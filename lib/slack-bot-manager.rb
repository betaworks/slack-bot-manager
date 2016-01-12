# Core requirements
require 'logger'
require 'redis'
require 'slack-ruby-client'

# core components
require 'slack-bot-manager/version'
require 'slack-bot-manager/errors'
require 'slack-bot-manager/logger'
require 'slack-bot-manager/config'

# bot client connection
require 'slack-bot-manager/client/commands'
require 'slack-bot-manager/client/base'

# connection manager
require 'slack-bot-manager/manager/connection'
require 'slack-bot-manager/manager/tokens'
require 'slack-bot-manager/manager/base'