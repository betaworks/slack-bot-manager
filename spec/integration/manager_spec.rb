require 'spec_helper'

RSpec.describe 'integration test', skip: !ENV['SLACK_API_TOKEN'] && 'missing SLACK_API_TOKEN' do
  around do |ex|
    WebMock.allow_net_connect!
    VCR.turned_off { ex.run }
    WebMock.disable_net_connect!
  end

  before do
    Thread.abort_on_exception = true

    # Set quicker check interval
    SlackBotManager::Config.reset
    SlackBotManager::Manager.configure do |config|
      config.check_interval = 1 # check every second while in spec mode
      config.log_level = ::Logger::WARN
    end
  end

  after do
    SlackBotManager::Config.reset
  end

  let(:manager) { SlackBotManager::Manager.new }

  let(:thr) { nil }

  # Start and run monitor in thread
  def start_manager
    manager.start
    thr = Thread.new { manager.monitor }
    sleep 2
  end
  def stop_manager
    manager.stop
    thr.exit rescue nil
    sleep 1
  end


  context 'manager started' do
    context 'with client token' do
      # Start manager, remove token on complete
      before { start_manager }
      after { stop_manager }

      it 'can add, check, update, and remove a token' do
        # Add and remove
        manager.add_token ENV['SLACK_API_TOKEN']
        sleep 3
        manager.remove_token ENV['SLACK_API_TOKEN']
        sleep 3

        # Add and check status
        manager.add_token ENV['SLACK_API_TOKEN']
        sleep 3
        status = manager.check_token ENV['SLACK_API_TOKEN']
        fail if !status || status.empty?
        sleep 3

        # Update token and remove
        manager.update_token ENV['SLACK_API_TOKEN']
        sleep 1
        manager.remove_token ENV['SLACK_API_TOKEN']
      end
    end

    context 'with commands' do
      # Add/remove tokens to have it do RTM/WSS handshakes
      before { manager.add_token ENV['SLACK_API_TOKEN'] }
      after { manager.remove_token ENV['SLACK_API_TOKEN'] }

      it 'start' do
        manager.start
      end
      it 'stop' do
        manager.start
        sleep 1
        manager.stop
      end
      it 'restart' do
        manager.start
        sleep 1
        manager.restart
      end
      it 'monitor' do
        manager.start
        thr = Thread.new { manager.monitor }
        # Let it run for a few seconds before killing
        sleep 3
        fail unless thr.status # nil or false means error
        thr.exit
      end
      it 'status' do
        manager.start
        manager.status
      end
    end
  end
end