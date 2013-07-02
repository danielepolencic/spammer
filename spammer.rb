require 'sinatra'
require 'liquid'
require 'liquid_blocks'
require './lib/spammer.rb'

get "/" do
  liquid :index
end

get "/setup" do
  liquid :setup
end

post "/spam" do
  receivers = []
  rows = params[:receivers].split "\n"
  for row in rows do
    unless row.strip.empty?
      email, name = row.split ','
      receivers << { :email => email.strip, :name => name.strip }
    end
  end
  layout { template = params[:template] }
  spammer = Spammer.new params[:username], params[:password]
  log = []
  for receiver in receivers do
    html = text = liquid "building the template", :locals => receiver
    begin
      spammer.spam({
        :subject => params[:subject],
        :to => receiver[:email],
        :text => text,
        :html => html
      })
      log.push "Processing #{ receiver[:email] }\n"
    rescue
      log.push "Error processing #{ receiver[:email] }\n"
    end
  end
  spammer.logout
  "<pre>#{ log.join '' }</pre>"
end
