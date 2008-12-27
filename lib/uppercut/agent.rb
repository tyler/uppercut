class Uppercut
  class Agent < Base
    VALID_CALLBACKS = [:signon, :signoff, :subscribe, :unsubscribe, :subscription_approval,
                       :subscription_denial, :status_change, :status_message_change]

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
        @@patterns ||= []
        g = gensym
        @@patterns << [pattern,g]
        define_method(g, &block)
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
        raise 'Not a valid callback' unless VALID_CALLBACKS.include?(type)
        define_method("__on_#{type.to_s}") { |conversation| block[conversation] }
      end

      private

      def gensym
        ('__uc' + (self.instance_methods.grep(/^__uc/).size).to_s.rjust(8,'0')).intern
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
    def listen
      connect unless connected?

      @listen_thread = Thread.new {
        @client.add_message_callback do |message|
          log_and_continue do
            next if message.body.nil?
            next unless allowed_roster_includes?(message.from)
            dispatch message
          end
        end

        @roster ||= Jabber::Roster::Helper.new(@client)
        @roster.add_presence_callback do |item, old_presence, new_presence|
          # Callbacks:
          # post-subscribe initial stuff (oldp == nil)
          # status change: (oldp.show != newp.show)
          # status message change: (oldp.status != newp.status)

          log_and_continue do
            if old_presence.nil? && new_presence.type == :unavailable
              dispatch_presence :signoff, new_presence
            elsif old_presence.nil?
              # do nothing, we don't care
            elsif old_presence.type == :unavailable && new_presence
              dispatch_presence :signon, new_presence
            elsif old_presence.show != new_presence.show
              dispatch_presence :status_change, new_presence
            elsif old_presence.status != new_presence.status
              dispatch_presence :status_message_change, new_presence
            end
          end
        end
        @roster.add_subscription_request_callback do |item,presence|
          # Callbacks:
          # someone tries to subscribe (presence.type == 'subscribe')

          log_and_continue do
            case presence.type
            when :subscribe
              next unless allowed_roster_includes?(presence.from)
              @roster.accept_subscription(presence.from)
              @roster.add(presence.from, nil, true)
              dispatch_presence :subscribe, presence
            end
          end
        end
        @roster.add_subscription_callback do |item, presence|
          # Callbacks:
          # user allows agent to subscribe to them (presence.type == 'subscribed')
          # user denies agent subscribe request (presence.type == 'unsubscribed')
          # user unsubscribes from agent (presence.type == 'unsubscribe')

          log_and_continue do
            case presence.type
            when :subscribed
              dispatch_presence :subscription_approval, presence
            when :unsubscribed
              # if item.subscription != :from, it's not a denial... it's just an unsub
              dispatch_presence(:subscription_denial, presence) if item.subscription == :from
            when :unsubscribe
              dispatch_presence :unsubscribe, presence
            end
          end
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
    
    attr_accessor :allowed_roster, :roster

    private

    def log_and_continue
      yield
    rescue => e
      log e
      raise if @debug
    end

    def dispatch(msg)
      bare_from = msg.from.bare
      block = @redirects[bare_from].respond_to?(:shift) && @redirects[bare_from].shift
      return block[msg.body] if block

      captures = nil
      pair = @@patterns.detect { |pattern,method| captures = matches?(pattern,msg.body) }
      if pair
        pattern, method = pair if pair
        send method, Conversation.new(msg.from,self), captures
      end
    end

    def dispatch_presence(type, presence)
      handler = "__on_#{type}"
      self.send(handler, Conversation.new(presence.from, self), presence) if respond_to?(handler)
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
