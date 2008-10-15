# Based on the merb-core Rakefile.  Thanks.

require "rake"
require "rake/clean"
require "rake/gempackagetask"
require "rake/rdoctask"
require "spec/rake/spectask"
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

spec = eval(File.read(File.join(File.dirname(__FILE__), 'uppercut.gemspec')))

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


##############################################################################
# Specs
##############################################################################
desc "Run all specs"
Spec::Rake::SpecTask.new('specs') do |t|
  t.spec_files = FileList['specs/*_spec.rb']
end
