About
=====

Headhunter is giving Twitter avatars a permanent URL.

In the words of [Remy Sharp](http://remysharp.com/), creator of the late Twivatar:

> If you've built an app that caches a Twitter user's avatar,
> and that user changes their avatar, the link breaks, thus breaking your app.

Let this tiny Sinatra app do the hunting for you.

Usage
=====

        <img src="http://headhunter.heroku.com/[username]" />

Unlike Twivatar, you can't specify a size. If you feel like it, hack away and send me a patch.

If this app doesn't work as advertized, it may have exceeded the Twitter API rate limit.
(Check if the Google-O-Meter on the [homepage](http://headhunter.heroku.com) is in the red area.)  
In that case, please consider **deploying your own copy** on Heroku.

Why not self-host Twivatar?
===========================

For a number of reasons (this list has grown since I started working on headhunter):

1. It **didn't work** out of the box
2. There is **no documentation** -- which is what you'd need if you face reason #1
3. There are **no tests** -- which is what you'd need if you face reasons #1 and #2
4. It uses a **relational database for caching**
5. It uses `REPLACE`, a MySQL extension to the SQL standard, which **locks you in**