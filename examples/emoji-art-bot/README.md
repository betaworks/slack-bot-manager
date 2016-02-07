# emoji art bot

an example bot using [slack-bot-manager](https://github.com/betaworks/slack-bot-manager) :sparkles:

slack-bot-manager depends on `redis` and `slack-ruby-client`

## usage
`emoji art [set] [size]`  
`set` and `size` are optional

to get a list of available emoji sets, do `emoji help`

around the 28-40 size range, messages may be too large to send back to Slack- if you get no response, try a smaller request.

examples:  
`emoji art shapes 20`  
`emoji artist, make me art`  
`make emoji art that's 10x10 and made of nature`

![](http://i.imgur.com/d3Y0R1X.png)

## get started

1. `touch .env`
2. add your Slackbot's token to `.env`
3. `bundle install`
4. `ruby bot.rb`

## custom emoji sets

1. add your set to `lib/json/emoji.json`
2. near line 26 of `lib/slack.rb`, there's a case statement- add your keywords and set here (make sure you place it before the else statement)

for example, to add a set called "buildings" that is used when the user says "buildings" or "city":
```
when message.include?("buildings") || message.include?("city")
	group = "buildings"
```

## todo
- add an `emoji again` command to do the last command again

![](http://i.imgur.com/oZIs3A4.png)


# credits

created by [Alex Baldwin](http://goose.im)
