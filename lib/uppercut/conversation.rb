class Uppercut
  class Conversation < Message
    attr_reader :to

    def initialize(to,base) #:nodoc:
      @to = to
      super base
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
      @base.redirect_from(@to,&block)
    end

  end
end
