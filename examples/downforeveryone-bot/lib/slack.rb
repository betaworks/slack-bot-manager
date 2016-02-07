module SlackBotManager
  module Commands

    def on_hello(data)
      debug(data)
    end

    def on_message(data)
      debug(data)

			message = data['text'].downcase

      site_by_word = /is (\w{2,}) (?:down|up)/
      site_by_url = /is (\w{2,}\.\w{1,}) (?:down|up)/
      site_by_link = /is <https?:\/\/[a-zA-Z\.]+\|((?:www.)\w{2,}\.\w\w{1,})> (?:down|up)/

      if message =~ site_by_word
        word = site_by_word.match(message)[1]
        url = Status.findurl(word)
        if (url)
          send_message(Status.isitdown(url), channel: data['channel'], icon_emoji: ":ok:")
        end
      end

      if message =~ site_by_url
        url = site_by_url.match(message)[1]
        send_message(Status.isitdown(url), channel: data['channel'], icon_emoji: ":ok:")
      end

      if message =~ site_by_link
        url = site_by_link.match(message)[1]
        send_message(Status.isitdown(url), channel: data['channel'], icon_emoji: ":ok:")
      end

    end

  end
end
