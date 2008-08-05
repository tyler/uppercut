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
end
