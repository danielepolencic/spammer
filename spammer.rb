require 'sinatra'
require 'liquid'
require 'liquid_blocks'
require 'pony'




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
      Pony.mail(
        :from => "#{ params[:name] } <#{ params[:username] }>",
        :to => "#{ receiver[:email] }"
        :subject => "#{ params[:subject] }"
        :body => text,
        :html_body => html,
        :port => '587',
        :via => :smtp,
        :via_options => {
          :address => 'smtp.sendgrid.net',
          :port => '587',
          :domain => 'heroku.com',
          :user_name => ENV['SENDGRID_USERNAME'],
          :password => ENV['SENDGRID_PASSWORD'],
          :authentication => :plain,
          :enable_starttls_auto => true
        })
      log.push "Processing #{ receiver[:email] }\n"
    rescue
      log.push "Error processing #{ receiver[:email] }\n"
    end
  end
  spammer.logout
  "<pre>#{ log.join '' }</pre>"
end
