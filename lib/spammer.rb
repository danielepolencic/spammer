require 'gmail'

class Spammer

  def initialize( username, password )
    @gmail = Gmail.connect(username, password)
  end

  def spam( email_settings )
    begin
      @gmail.deliver do
        to email_settings[:to]
        subject email_settings[:subject]
        text_part do
          body email_settings[:text]
        end
        html_part do
          content_type "text/html; charset=UTF-8"
          body email_settings[:html]
        end
      end
    rescue
      raise "Error parsing mail to #{email_settings[:to]}"
    end
  end

  def logout
    @gmail.logout
  end

end
