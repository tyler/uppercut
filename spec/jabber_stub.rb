Object.send(:remove_const, :Jabber)
class Jabber
  class Client
    def initialize(user)
      @user = user
    end
    
    def connect
      @connected = true
    end
    
    def auth(pw)
      @pw = pw
    end
    
    def is_connected?
      @connected
    end
    
    def close
      @connected = nil
    end
    
    attr_reader :sent
    def send(msg)
      @sent ||= []
      @sent << msg
    end
    
    attr_reader :on_message
    def add_message_callback(&block)
      @on_message = block
    end


    
    # TESTING HELPER METHODS
    
    def receive_message(from,body,type=:chat)
      msg = Message.new(nil)
      msg.type = type
      msg.body = body
      msg.from = from
      @on_message[msg]
    end
  end
  
  class Presence
    attr_accessor :from, :type, :show, :status

    def initialize(a,b)
    end
  end
  
  class Message
    attr_accessor :type, :body, :from
    def initialize(to)
      @to = to
    end
  end
  
  class Roster
    class Helper
      class RosterItem
        attr_accessor :subscription
      end

      def initialize(client)
        @client = client
      end
      
      def accept_subscription(a)
      end

      def add(a)
      end
   
      attr_reader :on_subscription_request
      def add_subscription_request_callback(&block)
        @on_subscription_request = block
      end

      def add_presence_callback(&block)
        @on_presence = block
      end

      def add_subscription_callback(&block)
        @on_subscription = block
      end

      # TESTING HELPER METHODS

      def receive_presence(item, old_presence, new_presence)
        @on_presence[item, old_presence, new_presence]
      end

      def receive_subscription(item, presence)
        @on_subscription[item, presence]
      end

      def receive_subscription_request(item, presence)
        @on_subscription_request[item, presence]
      end
    end
  end

  class JID
    def self.fake_jid
      new 'foo', 'bar.com', 'baz'
    end

    def initialize(node,domain,res)
      @node, @domain, @res = node, domain, res
    end

    def bare
      self.class.new @node, @domain, nil
    end
  end
end

