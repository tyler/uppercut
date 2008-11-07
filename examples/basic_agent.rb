class BasicNotifier < Uppercut::Notifier
  notifier :basic do |n,data|
    n.to 'tyler@codehallow.com'
    n.send 'Hey kid.'
  end
end

class BasicAgent < Uppercut::Agent
  command 'date' do |m|
    m.send `date`
  end
  
  command /^cat (.*)/ do |m,rest|
    m.send File.read(rest)
  end
  
  command 'report' do |m|
    m.send 'Hostname: ' + `hostname`
    m.send 'Running as: ' + ENV['USER']
  end
  
  command 'dangerous' do |c|
    c.send "Are you sure?!"
    c.wait_for do |reply|
      c.send %w(yes y).include?(reply.downcase) ? "Okay!  Done boss!" : "Cancelled!"
    end
  end
end
