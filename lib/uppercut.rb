# TODO: send files
# TODO: auto-reconnect
# TODO: MUC?  any use for this?

require 'rubygems'
require 'xmpp4r'
require 'xmpp4r/roster'


class Uppercut
  VERSION = "0.0.3"

  class Agent
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

      private

      def gensym
        '__uc' + (self.instance_methods.grep(/^__uc/).size).to_s.rjust(8,'0')
      end
    end

    # Create a new instance of an Agent, possibly connecting to the server.
    #
    # user should be a String in the form: "user@server/Resource".  pw is
    # simply the password for this account.  The final, and optional, argument
    # is a boolean which controls whether or not it will attempt to connect to
    # the server immediately.  Defaults to true.
    def initialize(user,pw,do_connect=true)
      @user = user
      @pw = pw
      connect if do_connect
      
      @redirects = {}
    end
    
    
    def inspect #:nodoc:
      "<Uppercut::Agent #{@user} " +
      "#{listening? ? 'Listening' : 'Not Listening'}:" +
      "#{connected? ? 'Connected' : 'Disconnected'}>"
    end

    # Attempt to connect to the server, if not already connected.
    #
    # Raises a simple RuntimeError if it fails to connect.  This should be
    # changed eventually to be more useful.
    def connect
      return if connected?
      connect!
      raise 'Failed to connected' unless connected?
      present!
    end

    # Disconnects from the server if it is connected.
    def disconnect
      disconnect! if connected?
    end

    # Disconnects and connects to the server.
    def reconnect
      disconnect
      connect
    end

    attr_reader :client, :roster
    
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
        @roster.add_subscription_request_callback do |item,presence|
          @roster.accept_subscription(presence.from)
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

    # True if the Agent is currently connected to the Jabber server.
    def connected?
      @client.respond_to?(:is_connected?) && @client.is_connected?
    end
    
    # True if the Agent is currently listening for incoming messages.
    def listening?
      @listen_thread && @listen_thread.alive?
    end
    
    def redirect_from(contact,&block)
      @redirects[contact] ||= []
      @redirects[contact].push block
    end
    
    
    
    def send_stanza(msg) #:nodoc:
      return false unless connected?
      send! msg
    end

    private
    
    def dispatch(msg)
      block = @redirects[msg.from].respond_to?(:shift) && @redirects[msg.from].shift
      return block[msg.body] if block
      
      self.methods.grep(/^__uc/).sort.detect { |m| send(m,msg) != :no_match }
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

    def connect!
      @connect_lock ||= Mutex.new
      return if @connect_lock.locked?
      
      client = Jabber::Client.new(@user)
      
      @connect_lock.lock

      client.connect
      client.auth(@pw)
      @client = client
      
      @connect_lock.unlock
    end

    def disconnect!
      @client.close if connected?
      @client = nil
    end
    
    def present!
      send! Jabber::Presence.new(nil,"Available")
    end
    
    # Taken direct from xmpp4r-simple (thanks Blaine!)
    def send!(msg)
      attempts = 0
      begin
        attempts += 1
        @client.send(msg)
      rescue Errno::EPIPE, IOError => e
        sleep 1
        disconnect!
        connect!
        retry unless attempts > 3
        raise e
      rescue Errno::ECONNRESET => e
        sleep (attempts^2) * 60 + 60
        disconnect!
        connect!
        retry unless attempts > 3
        raise e
      end
    end

    def log(error)
      # todo
      p error
    end

  end

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
