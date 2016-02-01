require 'spec_helper'

RSpec.describe SlackBotManager::Client, vcr: { cassette_name: 'web/rtm_start' } do
  let(:url) { 'wss://ms001.slack-msgs.com/websocket/abc123xox==' }

  before do
    @token = ENV.delete('SLACK_API_TOKEN')

    SlackBotManager::Config.reset
    SlackBotManager::Client.configure do |config|
      config.log_level = ::Logger::WARN
    end
  end

  after do
    ENV['SLACK_API_TOKEN'] = @token if @token
  end

  context 'iniitalize' do
    it 'requires a token' do
      client = SlackBotManager::Client.new('xoxb-abc123def456')
      expect(client.token).to eq 'xoxb-abc123def456'
    end
    it 'be disconnected' do
      client = SlackBotManager::Client.new('xoxb-abc123def456')
      expect(client.status).to eq :disconnected
    end
  end

  context 'connect' do
    it 'should succeed' do
      client = SlackBotManager::Client.new(@token)
      expect(client.connect).to eq :connected
      expect(client.connected?).to eq true
    end
  end

  context 'disconnect' do
    context 'should succeed' do
      [nil, :disconnected, :token_revoked, :rate_limited, :another_reason].each do |reason|
        it "on #{reason || 'nil'}" do
          client = SlackBotManager::Client.new(@token)
          client.connect
          expect(client.disconnect(reason)).to eq true
          expect(client.disconnected?).to eq true
          expect(client.status).to eq(reason || :disconnected)
        end
      end
    end
  end

  context 'send message' do
    context 'should succeed' do
      let(:client) { SlackBotManager::Client.new(@token) }

      it 'as socket message' do
        client.connect
        puts client.send_message('C123ABC', 'Hello!').inspect
      end

      it 'as post message'
      it 'as post message with attachments'
    end
  end

  context 'on/off methods' do
    it 'should succeed' do
      client = SlackBotManager::Client.new(@token)
      client.on :hello do
        return true
      end
      expect(client.respond_to?(:on_hello)).to be true
      expect(client.on_hello).to be true
      client.off :hello
      expect(client.respond_to?(:on_hello)).to be false
    end
  end

  context 'client methods' do
    let(:client) { SlackBotManager::Client.new(@token) }

    SlackBotManager::Config::RTM_CLIENT_METHODS.each do |name|
      it "on #{name}" do
        client = SlackBotManager::Client.new(@token)
        client.connect

        case name
        when :url
          expect(client.send("client_#{name}")).to eq(url)
        else
          expect(client.send("client_#{name}")).to be_an(Object)
        end
      end
    end
  end
end
