require 'sinatra'
require 'sinatra/json'
require 'rack/contrib/jsonp'
require 'liquid'
require 'liquid_blocks'
require 'pony'
require 'mail'
require 'json'
require 'multi_json'
require_relative 'config/config'

use Rack::JSONP

before '/send' do
  unless params[:api_key] && ( params[:api_key].to_i == settings.api_key.to_i )
    halt 403, {'Content-Type' => 'application/json'}, {:ok => false, :message => 'API KEY not valid.'}.to_json
  end

  unless validEmail?( params[:to_email] )
    halt 403, {'Content-Type' => 'application/json'}, { :ok => false, :message => 'Email not valid.' }.to_json
  end

  if params[:message].nil? || params[:subject].nil?
    halt 403, {'Content-Type' => 'application/json'}, { :ok => false, :message => 'Missing fields.' }.to_json
  end
end

get '/' do
  erb :usage
end

get '/send' do

  html = liquid params[:message], :locals => params
  text = if params[:text] then params[:text] else html end

  begin
    Pony.mail(
      :from => "#{ params[:from_name] } <#{ params[:from_email] }>",
      :to => "#{ params[:to_email] }",
      :subject => "#{ params[:subject] }",
      :body => text,
      :html_body => html,
      :port => '587',
      :via => settings.mail_settings[:via],
      :via_options => settings.mail_settings[:via_options])
  rescue Exception => e
    status 403
    return json :ok => false, :message => "#{ e.to_s }"
  end

  json :ok => true

end

def validEmail?( email )
  begin
   return false if email == ''
   parsed = Mail::Address.new( email )
   return parsed.address == email && parsed.local != parsed.address
  rescue Mail::Field::ParseError
    return false
  end
end
