require 'open-uri'
require 'json'

class HomeController < ApplicationController

  def index
    fetch_rumble_data
    fetch_events_data
  end

  def fetch_rumble_data
    url = 'http://localhost:8080/my/rumbles/1'
    content = open(url).read
    @rumble = JSON.parse(content)
  end

  def fetch_events_data
    url = 'http://localhost:8080/rumble_log/1'
    content = open(url).read
    json = JSON.parse(content)
    @events = events(json)
  end

  def events json
    events = json[":items"] || []
    messages = []
    events.each do |event|
      content = event["eventAt"][11..18]
      team = event["team"]
      fan = event["fan"]
      content += ' '

      content += team if team
      content += fan if fan

      event_name = event["event"]
      content += ', ' unless event_name.blank?
      content += event_name if event_name
      msge = event["message"]
      content += ', ' unless msge.blank?
      content += msge if msge

      diff = event[":type"] == "gameEvent" ? "+" : "-"
      health_value_adjust = event["healthValueAdjust"]
      if !health_value_adjust.blank? && health_value_adjust.to_i > 0
        content += ", Health #{diff}#{health_value_adjust}%"
      end

      attack_value_adjust = event["attackValueAdjust"]
      if !attack_value_adjust.blank?
        content += ", Attack #{diff}#{attack_value_adjust}"
      end

      messages << content
    end
    messages
  end

end
