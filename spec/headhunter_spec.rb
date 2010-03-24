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

  describe "Homepage" do

    it "should respond" do
      get '/'
      last_response.should be_ok
    end

    it "should show the remaining hits allowed by the Twitter API" do
      Net::HTTP.should_receive(:get).and_return({
        :reset_time_in_seconds => "1269200600",
        :remaining_hits => "123",
        :hourly_limit => "150"
      }.to_json)
      Time.should_receive(:now).and_return(now = mock('now', :to_i => 1269200000))
      get '/'
      last_response.body.should =~ /123/
      last_response.body.should =~ /reset to 150/
      last_response.body.should =~ /10[^0-9]+minutes/
    end

  end

end
