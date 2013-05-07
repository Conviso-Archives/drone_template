require "rubygems"
require 'xmpp4r/client'

# Jabber::debug = true

module Communication

  class XMPP
    def initialize(config = nil, debug = nil) # user,pass)
      @config = config
      @debug = debug
      @cl = Jabber::Client.new(Jabber::JID.new(@config['xmpp']['username']))
      @active = false
      __connenct()
    end

    # TODO: Fazer com que esse metodo apenas receba uma string com um payload
    def send_msg(issue = '', config = nil)
      @debug.info('Sending message ...')
      return true if issue.empty?
      return false if !self.active?
      begin
        msg = Jabber::Message.new(@config['xmpp']['importer_address'], build_xml(issue, config))
        msg.type = :normal
        @cl.send(msg)
      rescue
        @debug.error('Send message error')
        return false
      end

      sleep 0.8
      return true
    end

    def active?
      @active
    end

    private
    def __connenct
      begin
        @cl.connect
        @cl.auth(@config['xmpp']['password'])
        @cl.send(Jabber::Presence.new.set_type(:available))
        @active = true
      rescue
        @debug.error('Cannot connect to XMPP server. Please check network connection and XMPP credentials.')
      end 
    end
  end

end