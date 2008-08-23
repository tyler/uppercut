require 'rubygems'
require 'spec'

$: << File.dirname(__FILE__)
$: << File.join(File.dirname(__FILE__),'../lib')

# Loads uppercut and jabber
require 'uppercut'

# Unloads jabber, replacing it with a stub
require 'jabber_stub'

class TestAgent < Uppercut::Agent
  command 'hi' do |c|
    @called_hi = true
    c.send 'hello children!'
  end
  
  command /(good)?bye/ do |c,good|
    @called_goodbye = true
    c.send good ? "Good bye to you as well!" : "Rot!"
  end
  
  command 'wait' do |c|
    @called_wait = true
    c.send 'Waiting...'
    c.wait_for do |reply|
      @called_wait_block = true
      c.send 'Hooray!'
    end
  end
end