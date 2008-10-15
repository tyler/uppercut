require 'rubygems'
require 'xmpp4r'
require 'xmpp4r/roster'

%w(base agent notifier message conversation).each do |mod|
  require File.join(File.dirname(__FILE__), "uppercut/#{mod}")
end

