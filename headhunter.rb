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

  def google_chart
    ["http://chart.apis.google.com/chart?chs=400x250", "cht=gom", "chd=t:#{(@plot_value)}",
      "chco=FF0000,FF8040,FFFF00,00FF00,00FFFF,0000FF,800080", "chxt=x,y",
      "chxl=0:||1:|low|normal|plenty"].join("&")
  end
end

get '/favicon.ico' do
  status 404
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

get '/' do
  status_json = Net::HTTP.get(URI.parse("http://api.twitter.com/1/account/rate_limit_status.json"))
  status = JSON.parse(status_json)
  @remaining_hits = status['remaining_hits'].to_i
  @reset_to = status['hourly_limit']
  @reset_in_minutes = (status['reset_time_in_seconds'].to_i - Time.now.to_i)/60
  @plot_value = @reset_in_minutes == 0 ? 50 : (@remaining_hits * 1.0 / @reset_in_minutes * 20).round
  content_type 'text/html', :charset => 'utf-8'
  erb :index
end