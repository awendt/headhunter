require 'rubygems'
require 'bundler'

Bundler.require(:default, :test)

require 'headhunter'
require 'rack/test'

set :environment, :test

describe "Headhunter" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "should not respond to /favicon.ico and cache for a week" do
    get '/favicon.ico'
    last_response.should be_not_found
    last_response.headers['Cache-Control'].should =~ /max-age=604800$/
  end

  describe "Homepage" do

    it "should respond" do
      get '/'
      last_response.should be_ok
    end

    it "should show the remaining hits allowed by the Twitter API" do
      Twitter.should_receive(:get).and_return({
        "reset_time_in_seconds" => "1269200600",
        "remaining_hits" => "123",
        "hourly_limit" => "150"
      })
      Time.should_receive(:now).any_number_of_times.and_return(
        now = mock('now', :to_i => 1269200000).as_null_object)
      get '/'
      last_response.body.should =~ /123/
      last_response.body.should =~ /reset to 150/
      last_response.body.should =~ /10[^0-9]+minutes/
    end

    it "should cache for 3 minutes" do
      get '/'
      last_response.headers['Cache-Control'].should =~ /max-age=180$/
    end
  end

  describe "serving user avatars" do

    before do
      app.cache = mock(Dalli::Client, :get => nil, :set => nil)
    end

    describe 'having requested avatar in cache' do

      before do
        app.cache.stub(:get).with('awendt').and_return("http://cached_avatar.jpg")
        @mock_head_response = mock(HTTParty::Response)
        Twitter.stub!(:head).and_return(@mock_head_response)
      end

      describe "and it is not yet expired" do

        before do
          @mock_head_response.should_receive(:code).and_return(200)
        end

        it "should check the cached avatar with a HEAD request" do
          Twitter.should_receive(:head).with('http://cached_avatar.jpg').
              and_return(@mock_head_response)

          get '/awendt'
        end

        it "should redirect" do
          get '/awendt'

          last_response.should be_redirect
          last_response.headers['Location'].should == 'http://cached_avatar.jpg'
        end

        it "should instruct the client to cache for 10 minutes" do
          get '/awendt'

          last_response.headers['Cache-Control'].should =~ /max-age=600$/
        end

      end

      describe "but it expired" do

        before do
          @mock_head_response.should_receive(:code).and_return('404')
          Twitter.stub!(:get).and_return({"profile_image_url" => 'http://avatar.jpg'})
        end

        it "should fetch the avatar" do
          Twitter.should_receive(:get).and_return({"profile_image_url" => 'http://avatar.jpg'})

          get '/awendt'
        end

        it "should not verify the new URL" do
          Twitter.should_not_receive(:head).with('http://avatar.jpg')

          get '/awendt'
        end

        it "should redirect to the new URL" do
          get '/awendt'

          last_response.should be_redirect
          last_response.headers['Location'].should == 'http://avatar.jpg'
        end

        it "should instruct the client to cache for 10 minutes" do
          get '/awendt'

          last_response.headers['Cache-Control'].should =~ /max-age=600$/
        end

      end

    end

    describe 'without having requested avatar cached' do

      before do
        app.cache.stub!(:get).with('awendt').and_return(nil)
        Twitter.stub!(:get).and_return({"profile_image_url" => 'http://new_avatar.jpg'})
      end

      it "should fetch avatar from Twitter" do
        Twitter.should_receive(:get).and_return({"profile_image_url" => 'http://new_avatar.jpg'})

        get '/awendt'
      end

      it "should cache the avatar" do
        app.cache.should_receive(:set).with('awendt', 'http://new_avatar.jpg')

        get '/awendt'
      end

      it "should redirect" do
        get '/awendt'

        last_response.should be_redirect
        last_response.headers['Location'].should == 'http://new_avatar.jpg'
      end

      it "should not cache the default avatar" do
        Twitter.should_receive(:get).and_return({"profile_image_url" => DEFAULT_AVATAR})
        app.cache.should_not_receive(:set)

        get '/awendt'
      end

    end
  end
end
