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
  command 'hi' do |c,args|
    c.instance_eval { @base.instance_eval { @called_hi = true } }
    c.send 'called hi'
  end
  
  command /^hi/ do |c,args|
    c.instance_eval { @base.instance_eval { @called_hi_regex = true } }
    c.send 'called high regex'
  end
  
  command /(good)?bye/ do |c,args|
    @called_goodbye = true
    c.send args.first ? "Good bye to you as well!" : "Rot!"
  end
  
  command 'wait' do |c,args|
    @called_wait = true
    c.send 'Waiting...'
    c.wait_for do |reply|
      @called_wait_block = true
      c.send 'Hooray!'
    end
  end

  Uppercut::Agent::VALID_CALLBACKS.each do |cb|
    on(cb) { }
  end
end

class TestNotifier < Uppercut::Notifier
  notifier :foo do |m,data|
    m.to = 'foo@bar.com'
    m.send 'Foo happened!'
  end
end
