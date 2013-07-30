require 'hue_conference/event'

module HueConference
  class Calendar
    require 'google/api_client'

    attr_reader :id, :google_agent, :events

    def initialize(calendar_id, google_agent)
      @id = calendar_id
      @google_agent = google_agent
      @events = []
    end

    def sync_events!
      google_events_response = @google_agent.calendar_events(@id)

      return false if google_events_response.items.nil?

      build_events(google_events_response)
    end

    def build_events(google_events_response)
      @events.clear
      google_events_response.items.each do |event_hash|
        @events << HueConference::Event.new(event_hash)
      end
      return true
    end

    def next_event
      current_event ? @events[1] : @events.first
    end

    def current_event
      @events.find { |e| e.started? }
    end
  end
end
