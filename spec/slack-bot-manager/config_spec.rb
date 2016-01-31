require 'spec_helper'

describe SlackBotManager::Config do
  describe '#configure' do
    before do
      SlackBotManager.configure do |config|
        config.verbose = true
      end
    end

    after do
      SlackBotManager::Config.reset
    end

    it 'sets verbose mode' do
      expect(SlackBotManager.config.verbose).to eq true
    end
  end
end
