class Uppercut
  class Agent < Base
    class << self
      # Define a new command for the agent.
      # 
      # The pattern can be a String or a Regexp.  If a String is passed, it
      # will dispatch this command only on an exact match.  A Regexp simply
      # must match.
      #
      # There is always at least one argument sent to the block.  The first
      # is a always an Uppercut::Message object, which can be used to reply
      # to the sender.  The rest of the arguments to the block correspond to
      # any captures in the pattern Regexp. (Does not apply to String 
      # patterns).
      def command(pattern,&block)
        define_method(gensym) do |msg|
          return :no_match unless captures = matches?(pattern,msg.body)
          block[Conversation.new(msg.from,self),*captures]
        end
      end

      # Define a callback for specific presence events.
      #
      # At the moment this is only confirmed to work with :subscribe and :unsubscribe, but it may work with other types as well.
      # Example:
      #
      # on :subscribe do |conversation|
      #   conversation.send "Welcome! Send 'help' for instructions."
      # end
      #
      def on(type, &block)
        define_method("__on_#{type.to_s}__") { |conversation| block[conversation] }
      end

      private

      def gensym
        '__uc' + (self.instance_methods.grep(/^__uc/).size).to_s.rjust(8,'0')
      end
    end

    DEFAULT_OPTIONS = { :connect => true }
    
    # Create a new instance of an Agent, possibly connecting to the server.
    #
    # user should be a String in the form: "user@server/Resource".  pw is
    # simply the password for this account.  The final, and optional, argument
    # is a boolean which controls whether or not it will attempt to connect to
    # the server immediately.  Defaults to true.
    def initialize(user,pw,options={})
      options = DEFAULT_OPTIONS.merge(options)
      
      @user = user
      @pw = pw
      connect if options[:connect]
      listen if options[:listen]
      
      @allowed_roster = options[:roster]
      @redirects = {}
    end
    
    
    def inspect #:nodoc:
      "<Uppercut::Agent #{@user} " +
      "#{listening? ? 'Listening' : 'Not Listening'}:" +
      "#{connected? ? 'Connected' : 'Disconnected'}>"
    end

    # Makes an Agent instance begin listening for incoming messages and
    # subscription requests.
    #
    # Current listen simply eats any errors that occur, in the interest of
    # keeping the remote agent alive.  These should be logged at some point
    # in the future. Pass debug as true to prevent this behaviour.
    #
    # Calling listen fires off a new Thread whose sole purpose is to listen
    # for new incoming messages and then fire off a new Thread which dispatches
    # the message to the proper handler.
    def listen(debug=false)
      connect unless connected?

      @listen_thread = Thread.new {
        @client.add_message_callback do |message|
          next if message.body.nil?
          next unless allowed_roster_includes?(message.from)

          Thread.new do
            begin
              dispatch(message)
            rescue => e
              log e
              raise if debug
            end
          end
        end
        @roster ||= Jabber::Roster::Helper.new(@client)
        @roster.add_presence_callback do |item, oldp, newp|
          dispatch_presence(item, newp)
        end
        @roster.add_subscription_request_callback do |item,presence|
          next unless allowed_roster_includes?(presence.from)
          @roster.accept_subscription(presence.from) 
          dispatch_presence(item, presence)
        end
        @roster.add_subscription_callback do |item, presence|
          dispatch_presence(item, presence)
        end
        sleep
      }
    end

    # Stops the Agent from listening to incoming messages.
    #
    # Simply kills the thread if it is running.
    def stop
      @listen_thread.kill if listening?
    end

    # True if the Agent is currently listening for incoming messages.
    def listening?
      @listen_thread && @listen_thread.alive?
    end
    
    def redirect_from(contact,&block)
      @redirects[contact] ||= []
      @redirects[contact].push block
    end
    
    attr_accessor :allowed_roster

    private

    def dispatch(msg)
      bare_from = msg.from.bare
      block = @redirects[bare_from].respond_to?(:shift) && @redirects[bare_from].shift
      return block[msg.body] if block

      self.methods.grep(/^__uc/).sort.detect { |m| send(m,msg) != :no_match }
    end

    def dispatch_presence(item, presence)
      handler_method = "__on_#{presence.type.to_s}__"
      self.send(handler_method, Conversation.new(presence.from, self)) if respond_to?(handler_method)
    end

    def __ucDefault(msg)
      Message.new(msg.from,self).send("I don't know what \"#{msg.body}\" means.")
    end

    def matches?(pattern,msg)
      captures = nil
      case pattern
      when String
        captures = [] if pattern == msg
      when Regexp
        match_data = pattern.match(msg)
        captures = match_data.captures if match_data
      end
      captures
    end

    def allowed_roster_includes?(jid)
      return true unless @allowed_roster
      
      jid = jid.to_s
      return true if @allowed_roster.include?(jid)
      return true if @allowed_roster.include?(jid.sub(/\/[^\/]+$/,''))
    end

  end
end
