# TODO: send files
# TODO: auto-reconnect
# TODO: spin off listens into their own threads
# TODO: restart (stop-unload-reload-start) agents -- useful for updates
# TODO: MUC?  any use for this?

require 'rubygems'
require 'xmpp4r-simple'
require 'digest/md5'

class Uppercut
  VERSION = "0.0.1"
  
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
    
    attr_reader :client
    
    def initialize(user,pw)
      @user = user
      @pw = pw
      @client = Jabber::Simple.new(user,pw)
    end

    def listen(mode=:normal)
      loop do  
        begin
          @client.received_messages { |msg| dispatch(msg) }
        rescue Exception => e
          raise if mode == :debug
        end
        sleep 0.2
      end
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
  end
  
  class Message
    def initialize(from,agent)
      @from = from
      @agent = agent
    end
    
    def send(m)
      @agent.client.deliver(@from,m)
    end
  end
end
