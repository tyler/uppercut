class Uppercut
  class Notifier < Base
    def initialize(user,pw,options={})
      options = DEFAULT_OPTIONS.merge(options)
      
      @user = user
      @pw = pw
      connect if options[:connect]
    end

    DEFAULT_OPTIONS = { :connect => true }

  end
end
