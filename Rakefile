# Based on the merb-core Rakefile.  Thanks.

require "rake"
require "rake/clean"
require "rake/gempackagetask"
require "rake/rdoctask"
require "fileutils"

require File.dirname(__FILE__) + "/lib/uppercut"

include FileUtils

NAME = "uppercut"

##############################################################################
# Packaging & Installation
##############################################################################
CLEAN.include ["**/.*.sw?", "pkg", "lib/*.bundle", "*.gem", "doc/rdoc", ".config", "coverage", "cache"]

windows = (PLATFORM =~ /win32|cygwin/) rescue nil
install_home = ENV['GEM_HOME'] ? "-i #{ENV['GEM_HOME']}" : ""

SUDO = windows ? "" : "sudo"

desc "Packages Uppercut."
task :default => :package

task :uppercut => [:clean, :rdoc, :package]

spec = Gem::Specification.new do |s|
  s.name         = NAME
  s.version      = Uppercut::VERSION
  s.platform     = Gem::Platform::RUBY
  s.author       = "Tyler McMullen"
  s.email        = "tbmcmullen@gmail.com"
  s.homepage     = "http://codehallow.com"
  s.summary      = "Uppercut.  DSL for putting Jabber to work for you."
  s.bindir       = "bin"
  s.description  = s.summary
  s.require_path = "lib"
  s.files        = %w( LICENSE README Rakefile ) + Dir["{docs,bin,lib,examples}/**/*"]

  # Dependencies
  s.add_dependency "xmpp4r"
  s.add_dependency "xmpp4r-simple"
end

Rake::GemPackageTask.new(spec) do |package|
  package.gem_spec = spec
end

desc "Run :package and install the resulting .gem"
task :install => :package do
  sh %{#{SUDO} gem install #{install_home} --local pkg/#{NAME}-#{Uppercut::VERSION}.gem --no-rdoc --no-ri}
end

desc "Run :clean and uninstall the .gem"
task :uninstall => :clean do
  sh %{#{SUDO} gem uninstall #{NAME}}
end

##############################################################################
# Documentation
##############################################################################
task :doc => [:rdoc]
namespace :doc do

  Rake::RDocTask.new do |rdoc|
    files = ["README", "LICENSE", "CHANGELOG", "lib/**/*.rb"]
    rdoc.rdoc_files.add(files)
    rdoc.main = "README"
    rdoc.title = "Uppercut Docs"
    rdoc.rdoc_dir = "doc/rdoc"
    rdoc.options << "--line-numbers" << "--inline-source"
  end

end
