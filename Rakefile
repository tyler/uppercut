require "rake"
require "rake/clean"
require "rake/gempackagetask"
require "rake/rdoctask"
require "spec/rake/spectask"
require "fileutils"

require File.dirname(__FILE__) + "/lib/uppercut"

include FileUtils

NAME = "uppercut"

begin
  require 'rubygems'
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = NAME
    s.summary = "A DSL for writing agents and notifiers for Jabber."
    s.email = "tbmcmullen@gmail.com"
    s.homepage = "http://github.com/tyler/uppercut"
    s.description = s.summary
    s.authors = ["Tyler McMullen"]
    s.add_dependency 'xmpp4r'
    s.files = FileList["[A-Z]*.*", "{bin,generators,lib,test,spec,examples}/**/*"]
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end


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


desc "Run all specs"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/*_spec.rb']
end
