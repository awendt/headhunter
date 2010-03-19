require 'rubygems'
require 'sinatra'
require 'net/http'
require 'json'

configure do
  require 'memcached'
  CACHE = Memcached.new
end

helpers do
  def avatar_valid?(url)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host)
    http.request_head(uri.path).code == "200"
  end

  def grab_avatar_for(user)
    user_info = Net::HTTP.get(URI.parse("http://twitter.com/users/#{user}.json"))
    avatar_url = JSON.parse(user_info)["profile_image_url"]
    avatar_url ||= "http://static.twitter.com/images/default_profile_bigger.png"
  end
end

get '/status' do
  status = Net::HTTP.get(URI.parse("http://api.twitter.com/1/account/rate_limit_status.json"))
  "Remaining hits today: #{JSON.parse(status)['remaining_hits']}"
end

get '/:user' do
  user = params[:user]
  begin
    avatar_url = CACHE.get(user)
    raise Memcached::NotFound unless avatar_valid?(avatar_url)
  rescue Memcached::NotFound
    avatar_url = grab_avatar_for(user)
    CACHE.set(user, avatar_url)
  end
  redirect avatar_url
end
