require File.join(File.dirname(__FILE__), 'spec_helper')


describe Uppercut::Conversation do
  before(:each) do
    @conv = Uppercut::Conversation.new('test@foo.com', nil)
  end
  
  describe :contact do
    it "should have a contact method" do
      @conv.should.respond_to?(:contact)
    end
  end
end
