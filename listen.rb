require 'sinatra'
require_relative "./send_sms"
require_relative "./make_message"
post '/' do
  sender = params[:From]
  MartaBus.send_sms(sender, MartaBus.make_message)
end