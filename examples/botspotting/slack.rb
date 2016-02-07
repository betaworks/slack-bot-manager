require 'net/http'
require 'uri'
require 'json'

module SlackBotManager
  module Commands

    attr_accessor :team_name, :team_domain

    def on_hello(data)
      debug(data)
      @team_name = self.connection.web_client.team_info['team']['name']
      @team_domain = self.connection.web_client.team_info['team']['domain']
    end

    def on_bot_added(data)

      return if data['bot']['deleted'] == true

      subject = "someone added a bot to your team #{self.team_name}"
      message = "someone added the bot #{data['bot']['name']} to #{self.team_name}. \n
find out more at https://#{self.team_domain}.slack.com/apps/manage \n
[sent by botspotting]"

      # Send to Dexter webhook
      uri = URI(ENV['DEXTER_WEBHOOK'])
      req = Net::HTTP::Post.new(uri, initheader = {'Content-Type' =>'application/json'})
      req.body = {message: message, subject: subject}.to_json
      res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) do |http|
        http.request(req)
      end

      info(res.body)

    end

  end
end
