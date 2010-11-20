require 'sinatra'
require 'net/http'
require 'json'
require 'twitter'

configure do
  require 'memcached'
  CACHE = Memcached.new
end

DEFAULT_AVATAR = "http://static.twitter.com/images/default_profile_normal.png"

helpers do
  def avatar_valid?(url)
    Twitter.head(url).code == "200"
  end

  def grab_avatar_for(user)
    avatar_url = Twitter.get("/users/#{user}.json")["profile_image_url"]
    avatar_url ||= DEFAULT_AVATAR
  end

  def google_chart
    ["http://chart.apis.google.com/chart?chs=400x250", "cht=gom", "chd=t:#{(@plot_value)}",
      "chco=FF0000,FF8040,FFFF00,00FF00,00FFFF,0000FF,800080", "chxt=x,y",
      "chxl=0:||1:|low|normal|plenty"].join("&amp;")
  end

  def cache_for(time)
    response['Cache-Control'] = "public, max-age=#{time.to_i}"
  end
end

get '/favicon.ico' do
  cache_for 7*24*60*60
  status 404
end

get '/:user' do
  cache_for 10*60
  user = params[:user]
  begin
    avatar_url = CACHE.get(user)
    raise Memcached::NotFound unless avatar_valid?(avatar_url)
  rescue Memcached::NotFound
    avatar_url = grab_avatar_for(user)
    CACHE.set(user, avatar_url) unless avatar_url == DEFAULT_AVATAR
  end
  redirect avatar_url
end

get '/' do
  cache_for 3*60
  status = Twitter.get("/1/account/rate_limit_status.json")
  @remaining_hits = status['remaining_hits'].to_i
  @reset_to = status['hourly_limit']
  @reset_in_minutes = (status['reset_time_in_seconds'].to_i - Time.now.to_i)/60
  @plot_value = @reset_in_minutes == 0 ? 50 : (@remaining_hits * 1.0 / @reset_in_minutes * 20).round
  content_type 'text/html', :charset => 'utf-8'
  erb :index
end