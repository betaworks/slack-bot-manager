require 'spec_helper'

RSpec.describe 'client integration test', skip: !ENV['SLACK_API_TOKEN'] && 'missing SLACK_API_TOKEN' do
  around do |ex|
    WebMock.allow_net_connect!
    VCR.turned_off { ex.run }
    WebMock.disable_net_connect!
  end

  before do
    Thread.abort_on_exception = true

    SlackBotManager::Config.reset
    SlackBotManager::Client.configure do |config|
      config.log_level = ::Logger::WARN
    end
  end

  after do
    SlackBotManager::Config.reset
  end

  it 'client connection' do
    conn = SlackBotManager::Client.new(ENV['SLACK_API_TOKEN'])
    sleep 2
    fail unless conn.connected?
    fail if !conn.id || conn.id.empty?
    conn.disconnect
    sleep 2
    fail unless conn.disconnected?
  end
end
