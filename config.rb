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
  set :api_key, ENV['API_KEY']
end

configure :development do
  set :mail_settings, {
    :via => :sendmail,
    :via_options => {
      :location  => '/usr/sbin/sendmail',
      :arguments => '-t'
    }
  }
  set :api_key, 123
end
