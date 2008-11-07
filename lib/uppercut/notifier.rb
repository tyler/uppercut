class Uppercut
  class Notifier < Base
    class << self
      @@notifiers = []
      
      def notifier(name,&block)
        @@notifiers << name
        define_method(name, &block)
      end
    end

    def notify(name,data=nil)
      return false unless connected?
      return nil unless @@notifiers.include?(name)

      send(name,Message.new(self),data)
    end

    def initialize(user,pw,options={})
      options = DEFAULT_OPTIONS.merge(options)

      initialize_queue options[:starling], options[:queue]
      
      @user = user
      @pw = pw
      connect if options[:connect]
      listen if options[:listen]
    end

    DEFAULT_OPTIONS = { :connect => true }
    
    def listen
      connect unless connected?

      @listen_thread = Thread.new {
        loop { notify @starling.get(@queue) }
      }
    end

    def stop
      @listen_thread.kill if listening?
    end
    
    def listening?
      @listen_thread && @listen_thread.alive?
    end

    def inspect #:nodoc:
      "<Uppercut::Notifier #{@user} " +
      "#{listening? ? 'Listening' : 'Not Listening'} " + 
      "#{connected? ? 'Connected' : 'Disconnected'}>"
    end

    private

    def initialize_queue(server,queue)
      return unless queue && server      
      require 'starling'
      @queue = queue
      @starling = Starling.new(server)
    end

  end
end
