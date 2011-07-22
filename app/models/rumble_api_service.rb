class RumbleApiService
    include Singleton
    include HTTParty
    base_uri Settings.rumble_api_config.base_url
    format :json

    def entry_point      
      navigate
    end

    def profile
      navigate(entry_point["profile"])
    end

    def current_rumbles
      profile["currentRumbles"]
    end

    def get_first_rumble
      rumbles = current_rumbles
      raise "There are no rumbles created for this user" if rumbles[":count"].to_i == 0
      navigate(rumbles[":items"].first[":href"])
    end

    def get_event_log_for_first_rumble
      navigate(get_first_rumble["eventLog"])
    end

    def navigate(url = '/entry', params = {})
      response = self.class.get(url, query: params)
      content = JSON.parse(response.body)
      content["result"].present? && content["result"] == "error" ? raise_api_error(content) : content
    end

    protected
    
    def raise_api_error(error_json)
      message = error_json["errors"]["record"].present? ? error_json["errors"]["record"] : error_json["errors"]["general_error"]
      raise(RumbleApiError, "The Rumble API encountered the following error: #{message}")
    end
end

class RumbleApiError < Exception ; end
