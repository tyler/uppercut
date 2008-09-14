require File.join(File.dirname(__FILE__), 'spec_helper')

describe Uppercut::Agent do
  before :each do
    @agent = TestAgent.new('test@foo.com', 'pw', :connect => false)
  end
  
  describe :new do
    it "connects by default" do
      agent = Uppercut::Agent.new('test@foo','pw')
      agent.should be_connected
    end

    it "does not connect by default with :connect = false" do
      agent = Uppercut::Agent.new('test@foo','pw', :connect => false)
      agent.should_not be_connected
    end

    it "initializes @redirects with a blank hash" do
      agent = Uppercut::Agent.new('test@foo','pw', :connect => false)
      agent.instance_eval { @redirects }.should == {}
    end

    it "populates @pw and @user" do
      agent = Uppercut::Agent.new('test@foo','pw')
      agent.instance_eval { @pw }.should == 'pw'
      agent.instance_eval { @user }.should == 'test@foo'
    end
    
    it "populates @allowed_roster with :roster option" do
      jids = %w(bob@foo fred@foo)
      agent = Uppercut::Agent.new('test@foo','pw', :roster => jids)
      agent.instance_eval { @allowed_roster }.should == jids
    end
  end
  
  describe :connect do
    it "does not try to connect if already connected" do
      @agent.connect
      old_client = @agent.client

      @agent.connect
      (@agent.client == old_client).should == true
    end
    
    it "connects if disconnected" do
      @agent.should_not be_connected

      old_client = @agent.client
      
      @agent.connect
      (@agent.client == old_client).should_not == true
    end
    
    it "sends a Presence notification" do
      @agent.connect
      @agent.client.sent.first.class.should == Jabber::Presence
    end
  end
  
  describe :disconnect do
    it "does not try to disconnect if not connected" do
      @agent.client.should be_nil
      @agent.instance_eval { @client = :foo }
      
      @agent.disconnect
      @agent.client.should == :foo
    end
    
    it "sets @client to nil" do
      @agent.connect
      @agent.client.should_not be_nil
      
      @agent.disconnect
      @agent.client.should be_nil
    end
  end
  
  describe :reconnect do
    it "calls disconnect then connect" do
      @agent.should_receive(:disconnect).once.ordered
      @agent.should_receive(:connect).once.ordered

      @agent.reconnect
    end
  end
  
  describe :connected? do
    it "returns true if client#is_connected? is true" do
      @agent.connect
      @agent.client.instance_eval { @connected = true }
      @agent.should be_connected
    end
  end
  
  describe :listen do
    it "connects if not connected" do
      @agent.listen
      @agent.should be_connected
    end

    it "spins off a new thread in @listen_thread" do
      @agent.listen
      @agent.instance_eval { @listen_thread.class }.should == Thread
    end
    
    it "creates a receive message callback" do
      @agent.listen
      @agent.client.on_message.class.should == Proc
    end
    
    it "creates a subscription request callback" do
      @agent.listen
      @agent.roster.on_subscription_request.class.should == Proc
    end
    
    it "calls dispatch when receving a message" do
      @agent.listen
      @agent.should_receive(:dispatch)
      @agent.client.receive_message("foo@bar.com","test")
    end
  end
  
  describe :stop do
    it "kills the @listen_thread" do
      @agent.listen
      @agent.instance_eval { @listen_thread.alive? }.should == true
      
      @agent.stop
      @agent.instance_eval { @listen_thread.alive? }.should_not == true
    end
  end
  
  describe :listening? do
    it "returns true if @listen_thread is alive" do
      @agent.listen
      @agent.instance_eval { @listen_thread.alive? }.should == true
      @agent.should be_listening
    end
    
    it "returns false if @listen_thread is not alive" do
      @agent.listen
      @agent.stop
      @agent.should_not be_listening
    end
    
    it "returns false if @listen_thread has not been set" do
      @agent.should_not be_listening
    end
  end
  
  describe :dispatch do
    it "calls the first matching command" do
      msg = Jabber::Message.new(nil)
      msg.body = 'hi'
            
      @agent.send(:dispatch, msg)
      @agent.instance_eval { @called_hi_regex }.should_not == true
      @agent.instance_eval { @called_hi }.should == true
    end
    
    it "matches by regular expression" do
      msg = Jabber::Message.new(nil)
      msg.body = 'high'
      
      @agent.send(:dispatch, msg)
      @agent.instance_eval { @called_hi }.should_not == true
      @agent.instance_eval { @called_hi_regex }.should == true
    end
  end
end
