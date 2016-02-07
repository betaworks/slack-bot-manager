# "down for everyone or just me" bot

an example bot using [slack-bot-manager](https://github.com/betaworks/slack-bot-manager)

slack-bot-manager depends on `redis` and `slack-ruby-client`

# setup

1. get a free key for the [Bing Web-Only Search API](https://datamarket.azure.com/dataset/bing/searchweb)
2. your key will be under "My Account > Account Keys"
3. `touch .env` and then add the Bing key and your Slackbot token to `.env`
4. `ruby bot.rb`

# usage

`is [site] up` or `is [site] down`

site can be a url (like `google.com`) or a word (like `facebook`). using a word can be more time intensive and potentially less accurate, since it queries the [DuckDuckGo API
](https://api.duckduckgo.com/api) and Bing as a backup.

# credit

created by [Alex Baldwin](http://bldwn.co)
