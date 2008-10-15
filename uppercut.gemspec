Gem::Specification.new do |s|
  s.name         = 'uppercut'
  s.version      = '0.5.0'
  s.platform     = Gem::Platform::RUBY
  s.author       = "Tyler McMullen"
  s.email        = "tbmcmullen@gmail.com"
  s.homepage     = "http://codehallow.com"
  s.summary      = "Uppercut.  DSL for putting Jabber to work for you."
  s.bindir       = "bin"
  s.description  = s.summary
  s.require_path = "lib"
  s.files        = %w(LICENSE
                      README.textile
                      Rakefile
                      lib/uppercut.rb
                      lib/uppercut/agent.rb
                      lib/uppercut/base.rb 
                      lib/uppercut/conversation.rb
                      lib/uppercut/message.rb
                      lib/uppercut/notifier.rb
                      specs/agent_spec.rb
                      specs/conversation_spec.rb
                      specs/jabber_stub.rb
                      specs/notifier_spec.rb
                      specs/spec_helper.rb
                      examples/basic_agent.rb)

  # Dependencies
  s.add_dependency "xmpp4r"
end