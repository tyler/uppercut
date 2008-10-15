Gem::Specification.new do |s|
  s.name         = NAME
  s.version      = '0.5.0'
  s.platform     = Gem::Platform::RUBY
  s.author       = "Tyler McMullen"
  s.email        = "tbmcmullen@gmail.com"
  s.homepage     = "http://codehallow.com"
  s.summary      = "Uppercut.  DSL for putting Jabber to work for you."
  s.bindir       = "bin"
  s.description  = s.summary
  s.require_path = "lib"
  s.files        = %w(LICENSE README.textile Rakefile) + Dir["{docs,bin,lib,examples}/**/*"]

  # Dependencies
  s.add_dependency "xmpp4r"
end