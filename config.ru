require 'bundler/setup'
require 'sinatra/base'
require 'gmail'

# The project root directory
$root = ::File.dirname(__FILE__)

class SinatraStaticServer < Sinatra::Base  

  get(/.+/) do
    send_sinatra_file(request.path) {404}
  end

  post('/contact') do
    senders_name = params[:name]
    senders_email = params[:email]
    subject = params[:subject]
    message = params[:message]
    if params[:filter] == '' # this should be blank but bots try to fill out all the fields
      Gmail.new(ENV['GMAIL_USER'], ENV['GMAIL_PASS']) do |gmail|
        gmail.deliver do
          to 'milan@milandobrota.com'
          subject(subject)
          text_part do
            body "#{senders_name} (#{senders_email}) sent you a message: #{message}"
          end
        end
      end
      send_sinatra_file('email_sent')
    else
      'no form hacking'
    end
  end

  not_found do
    send_sinatra_file('404.html') {"Sorry, I cannot find #{request.path}"}
  end

  def send_sinatra_file(path, &missing_file_block)
    file_path = File.join(File.dirname(__FILE__), 'public',  path)
    file_path = File.join(file_path, 'index.html') unless file_path =~ /\.[a-z]+$/i  
    File.exist?(file_path) ? send_file(file_path) : missing_file_block.call
  end

end

run SinatraStaticServer
