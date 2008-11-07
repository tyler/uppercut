require File.join(File.dirname(__FILE__), 'spec_helper')

describe Uppercut::Notifier do
  before :each do
    @notifier = TestNotifier.new('test@foo.com', 'pw', :connect => false)
  end
  
  describe :new do
    it "connects by default" do
      notifier = Uppercut::Notifier.new('test@foo','pw')
      notifier.should be_connected
    end

    it "does not connect by default with :connect = false" do
      notifier = Uppercut::Notifier.new('test@foo','pw', :connect => false)
      notifier.should_not be_connected
    end
    
    it "populates @pw and @user" do
      notifier = Uppercut::Notifier.new('test@foo','pw')
      notifier.instance_eval { @pw }.should == 'pw'
      notifier.instance_eval { @user }.should == 'test@foo'
    end
  end
  
  describe :connect do
    it "does not try to connect if already connected" do
      @notifier.connect
      old_client = @notifier.client

      @notifier.connect
      (@notifier.client == old_client).should == true
    end
    
    it "connects if disconnected" do
      @notifier.should_not be_connected

      old_client = @notifier.client
      
      @notifier.connect
      (@notifier.client == old_client).should_not == true
    end
    
    it "sends a Presence notification" do
      @notifier.connect
      @notifier.client.sent.first.class.should == Jabber::Presence
    end
  end
  
  describe :disconnect do
    it "does not try to disconnect if not connected" do
      @notifier.client.should be_nil
      @notifier.instance_eval { @client = :foo }
      
      @notifier.disconnect
      @notifier.client.should == :foo
    end
    
    it "sets @client to nil" do
      @notifier.connect
      @notifier.client.should_not be_nil
      
      @notifier.disconnect
      @notifier.client.should be_nil
    end
  end
  
  describe :reconnect do
    it "calls disconnect then connect" do
      @notifier.should_receive(:disconnect).once.ordered
      @notifier.should_receive(:connect).once.ordered

      @notifier.reconnect
    end
  end
  
  describe :connected? do
    it "returns true if client#is_connected? is true" do
      @notifier.connect
      @notifier.client.instance_eval { @connected = true }
      @notifier.should be_connected
    end
  end
  
end
