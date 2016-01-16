$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'slack-bot-manager/version'

Gem::Specification.new do |s|
  s.name = 'slack-bot-manager'
  s.version = SlackBotManager::VERSION
  s.authors = ['Greg Leuch']
  s.email = 'greg@betaworks.com'
  s.platform = Gem::Platform::RUBY
  s.required_rubygems_version = '>= 1.3.6'
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- spec/*`.split("\n")
  s.require_paths = ['lib']
  s.homepage = 'http://github.com/betaworks/slack-bot-manager'
  s.licenses = ['MIT']
  s.summary = 'Slack RealTime API client connection manager.'

  s.add_dependency 'slack-ruby-client', '>=0.5.1'
  s.add_dependency 'faye-websocket', '>=0.10.0'
  s.add_dependency 'redis', '>=3.2.2'

  # s.add_development_dependency 'erubis'
  # s.add_development_dependency 'json-schema'
  # s.add_development_dependency 'rake'
  # s.add_development_dependency 'rspec'
  # s.add_development_dependency 'vcr'
  # s.add_development_dependency 'webmock'
  # s.add_development_dependency 'rubocop', '0.35.0'
end