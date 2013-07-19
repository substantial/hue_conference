require 'hue_conference/event'

module HueConference
  class Calendar
    require 'google/api_client'

    attr_reader :id, :events

    def initialize(calendar_id)
      @id = calendar_id
      @events = []
    end

    def build_events(google_events_response)
      @events.clear
      google_events_response.items.each do |event_hash|
        @events << HueConference::Event.new(event_hash)
      end
    end

    def next_event
      @events.sort.first
    end
  end
end
