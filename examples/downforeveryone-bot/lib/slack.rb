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
        typing(data['channel'])
        word = site_by_word.match(message)[1]
        url = Status.find_url(word)
        if (url)
          message(data['channel'], Status.isitdown(url), icon_emoji: ":ok:")
        end
      end

      if message =~ site_by_url
        typing(data['channel'])
        url = site_by_url.match(message)[1]
        message(data['channel'], Status.isitdown(url), icon_emoji: ":ok:")
      end

      if message =~ site_by_link
        typing(data['channel'])
        url = site_by_link.match(message)[1]
        message(data['channel'], Status.isitdown(url), icon_emoji: ":ok:")
      end
    end
  end
end
