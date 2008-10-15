require 'rubygems'
require 'spec'
require 'set'

$: << File.dirname(__FILE__)
$: << File.join(File.dirname(__FILE__),'../lib')

# Loads uppercut and jabber
require 'uppercut'

# Unloads jabber, replacing it with a stub
require 'jabber_stub'

class TestAgent < Uppercut::Agent
  command 'hi' do |c|
    c.instance_eval { @agent.instance_eval { @called_hi = true } }
    c.send 'called hi'
  end
  
  command /^hi/ do |c|
    c.instance_eval { @agent.instance_eval { @called_hi_regex = true } }
    c.send 'called high regex'
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

class TestNotifier < Uppercut::Notifier
  
end
