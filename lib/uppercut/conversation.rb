class Uppercut
  class Conversation
    attr_reader :contact
    def initialize(contact,agent) #:nodoc:
      @contact = contact
      @agent = agent
    end
    
    # Wait for another message from this contact.
    #
    # Expects a block which should receive one parameter, which will be a
    # String.
    #
    # One common use of _wait_for_ is for confirmation of a sensitive action.
    #
    #     command('foo') do |c|
    #       c.send 'Are you sure?'
    #       c.wait_for do |reply|
    #         do_it if reply.downcase == 'yes'
    #       end
    #     end
    def wait_for(&block)
      @agent.redirect_from(@contact,&block)
    end

    # Send a blob of text.
    def send(body)
      msg = Jabber::Message.new(@contact)
      msg.type = :chat
      msg.body = body
      @agent.send_stanza(msg)
    end
  end
end
