module HueConference
  class Event

    attr_reader :starting_time, :ending_time, :name, :callbacks

    DEFAULT_CALLBACKS = %w(starting finishing ending)

    def initialize(google_events_response)
      @name = google_events_response.summary.downcase.gsub(/\s/, '_')

      @starting_time = date_to_utc(google_events_response.start)
      @ending_time = date_to_utc(google_events_response.end)

      @callbacks = DEFAULT_CALLBACKS.map do |callback|
        OpenStruct.new(send(callback))
      end
    end

    def started?
      @starting_time < Time.now.utc
    end

    def finished?
      @ending_time < Time.now.utc
    end

    def underway?
      started? && !finished?
    end

    def unstarted?
      !started? && !finished?
    end

    private

    def date_to_utc(response_date)
      date = response_date.dateTime.nil? ? response_date.date : response_date.dateTime

      Time.parse(date.to_s).utc
    end

    def starting
      {
        type: 'starting',
        light:'outdoor',
        time: @starting_time,
        command: HueConference::Attribute.occupied
      }
    end

    def finishing
      {
        type: 'ending',
        light: 'outdoor',
        time: @ending_time - 20,
        command: HueConference::Attribute.ending
      }
    end

    def ending
      {
        type: 'ending',
        light: 'outdoor',
        time: @ending_time - 5,
        command: HueConference::Attribute.available
      }
    end
  end
end
