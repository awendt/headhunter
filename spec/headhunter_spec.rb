require File.dirname(__FILE__) + '/spec_helper'

describe "Headhunter" do
  include Rack::Test::Methods

  def app
    @app ||= Sinatra::Application
  end

  it "should not respond to /favicon.ico" do
    get '/favicon.ico'
    last_response.should be_not_found
  end

end

