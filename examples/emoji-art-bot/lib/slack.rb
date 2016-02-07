module SlackBotManager
  module Commands

    def on_hello(data)
      debug(data)
    end

    def on_message(data)
      debug(data)

			message = data['text'].downcase

			if message.include? "emoji" and (message.include? "list" or message.include? "help")
				list = "Usage: `emoji art [set] [size]` \n Emoji sets: `" + Emoji.list.join("`, `") + "`"
				send_message(list, channel: data['channel'])
				return
			end

      if message.include? "emoji" and message.include? "art"
				# Set grid size
        number = 4 # default
        if message =~ /\d/
          number = message.scan(/\d+/).first.to_i
        end
				# Set emoji group
				case
				when message.include?("positive") || message.include?("happy") || message.include?("funny") || message.include?("lol") || message.include?(":)")
					group = "positive"
				when message.include?("negative") ||message.include?("anger") || message.include?("sad") || message.include?("angry") || message.include?(":(")
					group = "negative"
				when message.include?("weather") || message.include?("forecast")
					group = "weather"
				when message.include?("nature") || message.include?("plants") || message.include?("flowers")
					group = "nature"
				when message.include?("animal") || message.include?("creature")
					group = "animals"
				when message.include?("moon")
					group = "moon"
				when message.include?("flag")
					group = "flags"
				when message.include?("clock")
					group = "clocks"
				when message.include?("tile") || message.include?("squares")
					group = "squares"
				when message.include?("shapes") || message.include?("pattern")
					group = "shapes"
				else
					group = "all" # default
				end
				Emoji.choose(group)
				# Send message
        send_message(Emoji.square(number), channel: data['channel'])
      end

    end

  end
end
