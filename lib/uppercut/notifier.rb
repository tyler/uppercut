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
      
      @user = user
      @pw = pw
      connect if options[:connect]
      listen if options[:listen]
    end

    DEFAULT_OPTIONS = { :connect => true }
    
    def inspect #:nodoc:
      "<Uppercut::Notifier #{@user} " +
      "#{listening? ? 'Listening' : 'Not Listening'}" + 
      "#{connected? ? 'Connected' : 'Disconnected'}>"
    end

  end
end
