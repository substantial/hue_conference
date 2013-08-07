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

    def current_events
      if event_underway
        [event_underway, next_starting_event]
      else
        [next_starting_event]
      end
    end

    def event_callbacks
      current_events.map(&:callbacks).flatten
    end

    private

    def find_event(type)
      @events.find { |event| event.send(type) }
    end

    def event_underway
      find_event(:underway?)
    end

    def next_starting_event
      find_event(:unstarted?)
    end
  end
end
