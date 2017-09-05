require 'twilio-ruby'
require 'yaml'

module MartaBus

  def self.send_sms(to_number, body, fake=false)
    secrets = YAML.load(open(File.join(File.dirname(__FILE__), "secrets.yaml")){|f| f.read })

    raise ArgumentError, "Your secrets.yaml file must have your Twilio sid and auth_token" unless secrets.has_key?("twilio") && secrets["twilio"].has_key?("sid") && secrets["twilio"].has_key?("auth_token") && secrets["twilio"].has_key?("phone_number")

    account_sid = secrets["twilio"]["sid"]
    auth_token =  secrets["twilio"]["auth_token"]

    from = secrets["twilio"]["phone_number"] # Your Twilio number
    client = Twilio::REST::Client.new account_sid, auth_token
    client.messages.create(
      from: from,
      to: to_number,
      body: body
    ) unless fake
    puts "Sent #{fake ? "fake " : ""}message to #{to_number} at #{Time.now}; said #{body}"
  end
end

if __FILE__ == $0
  to_number = ARGV[0]
  ARGV.clear
  body = gets.chomp
  MartaBus.send_sms(to_number, body)
end