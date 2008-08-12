# TODO: send files
# TODO: auto-reconnect
# TODO: spin off listens into their own threads
# TODO: restart (stop-unload-reload-start) agents -- useful for updates
# TODO: MUC?  any use for this?

require 'rubygems'
require 'xmpp4r'

class Uppercut
  VERSION = "0.0.2"

  class Agent
    class << self
      def command(pattern,&block)
        define_method(gensym) do |msg|
          return :no_match unless captures = matches?(pattern,msg.body)
          block[Message.new(msg.from,self),*captures]
        end
      end

      private

      def gensym
        '__uc' + (self.instance_methods.grep(/^__uc/).size - 1).to_s.rjust(8,'0')
      end
    end

    def initialize(user,pw,do_connect=true)
      @user = user
      @pw = pw
      connect if do_connect
    end

    def inspect
      "<Uppercut::Agent #{@user} #{connected? ? 'Connected' : 'Disconnected'}>"
    end

    def connect
      return if connected?
      connect!
      raise 'Failed to connected' unless connected?
      present!
    end

    def disconnect
      disconnect! if connected?
    end

    def reconnect
      disconnect
      connect
    end

    attr_reader :client
    
    def listen(debug=false)
      connect unless connected?
      @messages ||= []
      @client.add_message_callback do |message|
        Thread.new do
          begin
            dispatch(message)
          rescue => e
            log e
            raise if debug
          end
        end
      end
      loop { sleep(0.2) }
    end

    def dispatch(msg)
      d_to = self.methods.sort.grep(/^__uc/).detect { |m| send(m,msg) != :no_match }
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

    def connected?
      @client.respond_to?(:is_connected?) && @client.is_connected?
    end
    
    def send_stanza(msg)
      return false unless connected?
      send! msg
    end

    private

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
    end

  end

  class Message
    def initialize(to,agent)
      @to = to
      @agent = agent
    end

    def send(body)
      msg = Jabber::Message.new(@to)
      msg.type = :chat
      msg.body = body
      @agent.send_stanza(msg)
    end
  end
end
