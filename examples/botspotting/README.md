# botspotting

emails you (or just hits a webhook endpoint) when a new bot is added to your team

an example bot using [slack-bot-manager](https://github.com/betaworks/slack-bot-manager) and [dexter](https://rundexter.com/)

slack-bot-manager depends on `redis` and `slack-ruby-client`

# setup

1. make your Dexter app (see below), and get the webhook URL
2. `touch .env` and then add your Slackbot token and Dexter webhook URL to `.env`
3. `ruby bot.rb`

# making a dexter app

you can either build a dexter app from scratch for this or [use one we pre-built](https://rundexter.com/app/botspotting)

1. [sign up for Dexter](https://rundexter.com/signup)
2. in the top right, hit "New App" and name and describe the app ![](http://s.goose.im/screenshot20160115111705.png)
3. drag the "Webhook" trigger from the left and on to the canvas. click on it and, on the right, add two new variables- name them "message" and "subject" ![](http://s.goose.im/screenshot20160115135756.png)
4. back on the left, go to "Modules" and add a module- we're using Dexter Emailer, but you could use Dexter SMS, Twitter Tweeter, or anything else that takes text input
5. click on your new module and hit "Configure", and drag the "message" and "subject" variables from the Webhook to the Module. for the email module, that looks like this: ![](http://s.goose.im/screenshot20160115140235.png)
6. for the other inputs, you can either choose to prompt the user (we use this for the To field) or enter it manually. for Reply To, HTML Body, CC, and BCC, we choose to enter it manually but leave it blank
7. click Use App in the upper right to configure the app and get your webhook URL

# credit

created by [Alex Balwdin](http://goose.im)
