#require 'dotenv'
#Dotenv.load

require 'net/http'
require 'json'
require 'bing-search'

BingSearch.account_key = ENV['BING_SEARCH_KEY']
BingSearch.web_only = true

class Status

	def self.isitdown(url) # e.g. google.com
		uri = URI('http://downforeveryoneorjustme.com/' + url)
		output = Net::HTTP.get(uri)
		if output =~ /It's just you/i
			if url == 'encrypted.google.com'
				return "google.com is up :ok_hand:"
			else
				return "#{url} is up :ok_hand:"
			end
		else
			return "#{url} is down :warning:"
		end
	end

	def self.find_url(word)
		uri = URI('http://api.duckduckgo.com/?q=!' + word + '&format=json&t=downforeveryone-bot')
		output = Net::HTTP.get(uri)
		hash = JSON.parse(output)
		if hash['Redirect'] != ""
			return /https?:\/\/([\w{2,}\.]+)/.match(hash['Redirect'])[1]
		else
			return Status.search_url(word)
		end
	end

	def self.search_url(word)
		results = BingSearch.web(word, {:limit => 1})
		if results[0] and results[0].display_url
			return /(?:https?:\/\/)?([\w{2,}\.]+)/.match(results[0].display_url)[1]
		end
	end

end
