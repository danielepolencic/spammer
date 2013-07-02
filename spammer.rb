require 'sinatra'
require 'liquid'
require 'liquid_blocks'
require 'pony'

configure :production do
  set :mail_settings, {
    :via => :smtp,
    :via_options => {
      :address => 'smtp.sendgrid.net',
      :port => '587',
      :domain => 'heroku.com',
      :user_name => ENV['SENDGRID_USERNAME'],
      :password => ENV['SENDGRID_PASSWORD'],
      :authentication => :plain,
      :enable_starttls_auto => true
    }
  }
end

configure :development do
  set :mail_settings, {
    :via => :sendmail,
    :via_options => {
      :location  => '/usr/sbin/sendmail',
      :arguments => '-t'
    }
  }
end

get "/" do
  liquid :index
end

get "/setup" do
  liquid :setup
end

post "/spam" do
  recipients = []
  log = []

  unless params[:magic_password] == "spam123"
    return "Sorry, wrong password"
  end

  rows = params[:recipients].split "\n"
  for row in rows do
    unless row.strip.empty?
      email, name = row.split ','
      recipients << { :email => email.strip, :name => name.strip }
    end
  end

  layout { template = params[:email_message] }

  for recipient in recipients do
    html = text = liquid "building the template", :locals => recipient
    begin
      Pony.mail(
        :from => "#{ params[:sender_name] } <#{ params[:sender_email] }>",
        :to => "#{ recipient[:email] }",
        :subject => "#{ params[:email_subject] }",
        :body => text,
        :html_body => html,
        :port => '587',
        :via => settings.mail_settings[:via],
        :via_options => settings.mail_settings[:via_options])
      log.push "Processing #{ recipient[:email] }\n"
    rescue
      log.push "Error processing #{ recipient[:email] }\n"
    end
  end

  "<pre>#{ log.join '' }</pre>"
end
