About
=====

Headhunter is serving Twitter profile pictures from permanent URLs.

In the words of [Remy Sharp](http://remysharp.com/), creator of the late Twivatar:

> If you've built an app that caches a Twitter user's avatar,
> and that user changes their avatar, the link breaks, thus breaking your app.

Let this tiny Sinatra app do the hunting for you.

Usage
=====

        <img src="http://headhunter.heroku.com/[username]" />

Unlike Twivatar, you can't specify a size. If you feel like it, hack away and send me a patch.

When this app doesn't work as advertized, it may have exceeded the Twitter API rate limit.
In that case, please consider **deploying your own copy.**