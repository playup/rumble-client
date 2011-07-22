class RumbleApiService
  include Singleton
  include HTTParty
  base_uri Settings.rumble_api_config.base_url
  format :json

  def entry_point
    navigate
  end

  def profile
    navigate(entry_point["profile"]) if entry_point
  end

  def current_rumbles
    profile["currentRumbles"] if profile
  end

  def get_first_rumble
    if current_rumbles
      rumbles = current_rumbles
      raise "There are no rumbles created for this user" if rumbles[":count"].to_i == 0
      navigate(rumbles[":items"].first[":href"])
    end
  end

  def get_event_log_for_first_rumble
    begin
      navigate(get_first_rumble["eventLog"])
    rescue Exception => e
      Rails.logger.error("Exception encountered while parsing json")
      return nil
    end
  end

  def navigate(url = '/entry', params = {})

    response = self.class.get(url, query: params)
    JSON.parse(response.body)
  rescue Exception => e
    Rails.logger.error("Exception encountered while parsing json")
    Rails.logger.error(e)
    return nil
  end
end

