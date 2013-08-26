require 'hue_conference/event'

module HueConference
  class Calendar
    require 'google/api_client'

    def initialize(calendar_id, google_agent)
      @id = calendar_id
      @google_agent = google_agent
      @events = []
    end

    def sync_events!
      google_events_response = @google_agent.calendar_events(@id)

      return false if google_events_response.nil?

      build_events(google_events_response) unless google_events_response.items.empty?
    end

    def build_events(google_events_response)
      @events.clear
      google_events_response.items.each do |event_hash|
        @events << HueConference::Event.new(event_hash)
      end
    end

    def current_events
      @events[0..1]
    end

    def event_callbacks
      current_events.map(&:callbacks).flatten
    end

    private

    def find_event(type)
      @events.find { |event| event.send(type) }
    end
  end
end
