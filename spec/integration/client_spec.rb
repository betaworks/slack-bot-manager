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
    conn.connect
    sleep 2
    fail unless conn.connected?
    fail if !conn.id || conn.id.empty?
    conn.disconnect
    sleep 2
    fail unless conn.disconnected?
    sleep 2
  end

  context 'with commands' do
    let(:conn) { SlackBotManager::Client.new(ENV['SLACK_API_TOKEN']) }

    after do
      conn.off :hello
      conn.off :message
    end

    it 'can handle special commands' do
      hello = "Hello #{Time.now.to_i}"

      # On hello, say hello
      conn.on :hello do |_|
        channel = client_channels.keys.first
        message(channel, hello)
      end

      # Disconnect if message is not hello
      conn.on :message do |_|
        channel = client_channels.keys.first
        typing(channel)
        sleep 2
        message(channel, 'Bye!')
        disconnect
      end

      conn.connect
      sleep 5
      fail if conn.connected?
    end
  end
end
