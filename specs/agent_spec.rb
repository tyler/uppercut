require File.join(File.dirname(__FILE__), 'spec_helper')

describe Uppercut::Agent do
  before :each do
    @agent = Uppercut::Agent.new('test@foo.com', 'pw', false)
  end
  
  describe :new do
    it "should connect by default" do
      agent = Uppercut::Agent.new('test@foo','pw')
      agent.connected?.should == true
    end

    it "should not connect by default" do
      agent = Uppercut::Agent.new('test@foo','pw',false)
      agent.connected?.should_not == true
    end

    it "should initialize @redirects with a blank hash" do
      agent = Uppercut::Agent.new('test@foo','pw',false)
      agent.instance_eval { @redirects }.should == {}
    end

    it "should populate @pw and @user" do
      agent = Uppercut::Agent.new('test@foo','pw')
      agent.instance_eval { @pw }.should == 'pw'
      agent.instance_eval { @user }.should == 'test@foo'
    end
  end
  
  describe :connect do
    it "should not try to connect if already connected" do
      @agent.connect
      old_client = @agent.client

      @agent.connect
      (@agent.client == old_client).should == true
    end
    
    it "should connect if disconnected" do
      @agent.connected?.should_not == true

      old_client = @agent.client
      
      @agent.connect
      (@agent.client == old_client).should_not == true
    end
    
    it "should send a Presence notification" do
      @agent.connect
      @agent.client.sent.first.class.should == Jabber::Presence
    end
  end
  
  describe :disconnect do
    it "should not try to disconnect if not connected" do
      @agent.client.should == nil
      @agent.instance_eval { @client = :foo }
      
      @agent.disconnect
      @agent.client.should == :foo
    end
    
    it "should set @client to nil" do
      @agent.connect
      (!!@agent.client).should == true
      
      @agent.disconnect
      (!!@agent.client).should_not == true
    end
  end
  
  describe :reconnect do
    it "should call disconnect then connect" do
      hooks = Module.new
      hooks.send(:define_method, :connect, lambda { @called_connect = true })
      hooks.send(:define_method, :disconnect, lambda { @called_disconnect = true })
      @agent.extend(hooks)
      
      @agent.reconnect
      @agent.instance_eval { @called_disconnect }.should == true
      @agent.instance_eval { @called_connect }.should == true
    end
  end
  
  describe :connected? do
    it "should return true if client#is_connected? is true" do
      @agent.connect
      @agent.client.instance_eval { @connected = true }
      @agent.connected?.should == true
    end
  end
end
