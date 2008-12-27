Gem::Specification.new do |s|
  s.name = %q{uppercut}
  s.version = "0.7.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tyler McMullen"]
  s.date = %q{2008-12-27}
  s.description = %q{A DSL for writing agents and notifiers for Jabber.}
  s.email = %q{tbmcmullen@gmail.com}
  s.files = ["README.textile", "VERSION.yml", "lib/uppercut", "lib/uppercut/agent.rb", "lib/uppercut/base.rb", "lib/uppercut/conversation.rb", "lib/uppercut/message.rb", "lib/uppercut/notifier.rb", "lib/uppercut.rb", "spec/agent_spec.rb", "spec/conversation_spec.rb", "spec/jabber_stub.rb", "spec/notifier_spec.rb", "spec/spec_helper.rb", "examples/basic_agent.rb", "examples/personal.rb"]
  s.homepage = %q{http://github.com/tyler/uppercut}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{A DSL for writing agents and notifiers for Jabber.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_runtime_dependency(%q<xmpp4r>, [">= 0"])
    else
      s.add_dependency(%q<xmpp4r>, [">= 0"])
    end
  else
    s.add_dependency(%q<xmpp4r>, [">= 0"])
  end
end
