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
    def initialize(a,b)
    end
    
    def from
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
      def initialize(client)
        @client = client
      end
      
      def accept_subscription(a)
      end
      
      def add_subscription_request_callback(&block)
        @subscription_request_callback = block
      end
    end
  end
end