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
    sleep 2
  end

  context 'with commands' do
    before do
      module SlackBotManager
        module Commands
          def n
            @n ||= "Hello! #{Time.now.to_i}"
          end

          def on_hello(*)
            sleep 1
            channel = client_channels.first['id']
            send_message(channel, n)
          end

          def on_message(data)
            if data['text'] == n
              sleep 1
              send_message(data['channel'], "Bye! #{n}")
            else
              disconnect
            end
          end
        end
      end
    end

    after do
      module SlackBotManager
        module Commands
          remove_method :on_hello
          remove_method :on_message
        end
      end
    end

    it 'can handle special commands' do
      conn = SlackBotManager::Client.new(ENV['SLACK_API_TOKEN'])
      sleep 3
      fail if conn.connected?
    end
  end
end
