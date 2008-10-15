class Uppercut
  class Message
    attr_accessor :to, :message

    def initialize(base) #:nodoc:
      @base = base
    end

    # Send a blob of text.
    def send(body=nil)
      msg = Jabber::Message.new(@to)
      msg.type = :chat
      msg.body = body || @message
      @base.stanza(msg)
    end
  end
end

