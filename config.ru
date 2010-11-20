require 'rubygems'
require 'bundler'

Bundler.require

set :views, './views'
require 'headhunter'
run Sinatra::Application