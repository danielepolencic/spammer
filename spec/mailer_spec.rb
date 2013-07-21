require 'rack/test'
require_relative '../mailer'

API_KEY = 123
EMAIL = 'demo@test.it'

def app
  Sinatra::Application
end

describe 'Mailer' do
  include Rack::Test::Methods

  it 'should fail if there is no api key' do
    get '/send'
    last_response.should_not be_ok
  end

  it 'should fail if the api key is not correct' do
    get '/send', params = { api_key: 'wrongapi_key' }
    last_response.should_not be_ok
  end

  it 'should fail if the email is not correct' do
    get "/send", params = { api_key: API_KEY, to_email: 'wrongemail' }
    last_response.should_not be_ok
  end

  it 'should fail if message is empty' do
    get "/send", params = { api_key: API_KEY, to_email: EMAIL, subject: 'blabla' }
    last_response.should_not be_ok
  end

  it 'should fail if subject is empty' do
    get "/send", params = { api_key: API_KEY, to_email: EMAIL, message: 'blabla' }
    last_response.should_not be_ok
  end

  it 'should send an email' do
    get "/send", params = { api_key: API_KEY, to_email: EMAIL, message: 'blabla', subject: 'blabla' }
    last_response.should be_ok
  end

  it 'should correctly parse the template and send an email' do
    Pony.stub(:deliver)
    Pony.should_receive(:deliver) do |mail|
      mail.to.should == [ EMAIL ]
      mail.subject.should == 'blabla'
      mail.body.parts.first.body.include? 'Clark Kent'
    end
    get "/send", params = { api_key: API_KEY, to_email: EMAIL, message: 'Hello {{ to_name }}', subject: 'blabla', to_name: 'Clark Kent' }
    last_response.should be_ok
  end

  it 'should correctly parse a JSONP request and send an email' do
    get "/send", params = { api_key: API_KEY, to_email: EMAIL, message: 'Hello {{ to_name }}', subject: 'blabla', to_name: 'World', callback: 'mycallback' }
    last_response.should be_ok
    last_response.body.include? 'mycallback'
  end

end
