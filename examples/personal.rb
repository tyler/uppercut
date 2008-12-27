require 'rubygems'
require 'uppercut'
require 'yahoo-weather'
require 'feed_tools'

class PersonalAgent < Uppercut::Agent
  def get_weather
    @weather_client ||= YahooWeather::Client.new
    @weather_client.lookup_location('94102') # lookup by zipcode
  end

  def get_news
    FeedTools::Feed.open('feed://www.nytimes.com/services/xml/rss/nyt/HomePage.xml')
  end

  command 'weather' do |c,args|
    weather = get_weather
    c.send "#{weather.title}\n#{weather.condition.temp} degrees\n#{weather.condition.text}"
  end

  command 'forecast' do |c,args|
    response = get_weather
    msg = "#{response.forecasts[0].day} - #{response.forecasts[0].text}. "
    msg << "High: #{response.forecasts[0].high} Low: #{response.forecasts[0].low}\n"
    msg << "#{response.forecasts[1].day} - #{response.forecasts[1].text}. "
    msg << "High: #{response.forecasts[1].high} Low: #{response.forecasts[1].low}\n"
    c.send msg
  end

  command 'news' do |c,args|
    msg = get_news.items[0,5].map { |item|
      "#{item.title}\n#{item.link}"
    }.join("\n\n")
    c.send msg
  end
end

if $0 == __FILE__
  agent = PersonalAgent.new('name@domain.com/PersonalAgent','password')
  agent.listen
  sleep
end
