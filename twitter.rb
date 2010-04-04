require 'httparty'

class Twitter
  include HTTParty
  base_uri 'api.twitter.com'
end