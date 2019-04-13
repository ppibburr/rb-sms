require 'mail'
require 'json'

module SMS
  module Simple
    def self.configure opts={
                              "options": {
                                "address": "smtp.gmail.com",
                                "port": 587,
                                "user_name": "<myusername>",
                                "password": "<mypassword>",
                                "authentication": "plain",
                                "enable_starttls_auto": true
                              },
                              "method": "smtp",
                              "provider": "default",
                              "providers": {
                              }
                            }


      opts[:provider] = (opts[:provider] || :default).to_sym
      opts[:method]   = (opts[:method]   || :default).to_sym
      
      (opts[:providers] ||= {}).each do |n,a| 
        (PROVIDERS[n.to_sym] ||= []) << a
      end
      
      ::Mail.defaults do
        delivery_method opts[:method], opts[:options]
      end
    end
    
    PROVIDERS = {
      default: %w[
        email.uscc.net,
        message.alltel.com,
        messaging.sprintpcs.com,
        mobile.celloneusa.com,
        msg.telus.com,
        paging.acswireless.com,
        pcs.rogers.com,
        qwestmp.com,
        sms.ntwls.net,
        tmomail.net,
        txt.att.net,
        txt.windmobile.ca,
        vtext.com,
        text.republicwireless.com,
        msg.fi.google.com
      ]
    }
    
    def self.sms! opts={}
      Mail.deliver do
        to(PROVIDERS[(opts[:provider] ||= :default).to_sym].map do |e| "#{opts[:to]}@#{e}" end.join(","))  
        from(opts[:from] || "Ruby SMS")
        subject(opts[:subject] || "From Ruby SMS")
        body opts[:message]
      end
    end
  end
end

if __FILE__ == $0
  if ARGV.length < 2
    puts """USAGE:
ruby sms.rb <to> <message> [<config-file>]

Sends (Maybe) A SMS to a phone number
    
    """
    
    exit
  end

  cfg = File.expand_path(ARGV[2] || "#{ENV['HOME']}/.rb-sendsms-config.json")
  
  raise "NoSuchConfigFile: #{cfg}" unless File.exist?(cfg)
  
  SMS::Simple.configure opts=JSON.parse(open(cfg).read, symbolize_names: true)
  
  SMS::Simple.sms! to:       ARGV[0], 
                   message:  ARGV[1], 
                   provider: opts[:provider]
end
