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

    def current_events
      things = []
      current_event = events.first
      next_event = events[1]
      things << current_event if current_event
      things << next_event if next_event
      things
    end

    def event_callbacks
      current_events.map(&:callbacks).flatten
    end

    private

    def find_event(type)
      @events.find { |event| event.send(type) }
    end

#    def current_event
#      find_event(:underway?)
#    end
#
#    def next_event
#      find_event(:unstarted?)
#    end
  end
end
