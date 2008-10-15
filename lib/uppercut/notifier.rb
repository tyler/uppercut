class Uppercut
  class Notifier < Base
    class << self
      @@notifiers = {}
      
      def notifier(name,&block)
        @@notifiers[name] = block
      end
    end

    def notify(name,data=nil)
      return false unless connected?
      @@notifiers[name].call(Message.new(self),data)
    end

    def initialize(user,pw,options={})
      options = DEFAULT_OPTIONS.merge(options)
      
      @user = user
      @pw = pw
      connect if options[:connect]
    end

    DEFAULT_OPTIONS = { :connect => true }
    
    def inspect #:nodoc:
      "<Uppercut::Notifier #{@user} " +
      "#{connected? ? 'Connected' : 'Disconnected'}>"
    end

  end
end
