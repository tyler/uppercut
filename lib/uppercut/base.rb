class Uppercut
  class Base
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
    
    # True if the Agent is currently connected to the Jabber server.
    def connected?
      @client.respond_to?(:is_connected?) && @client.is_connected?
    end
    
    def send_stanza(msg) #:nodoc:
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
    
    # Taken directly from xmpp4r-simple (thanks Blaine!)
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
end
