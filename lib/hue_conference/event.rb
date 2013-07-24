class HueConference::Event
  include Comparable

  attr_reader :start_date, :end_date, :name

  def initialize(google_events_response)
    @name = google_events_response.summary

    @start_date = parse_date_time(google_events_response.start)
    @end_date = parse_date_time(google_events_response.end)
  end

  def <=>(other)
     @start_date <=> other.start_date
  end

  def started?
    @start_date < DateTime.now
  end

  private

  def parse_date_time(response_date)
    date_time = response_date.date ? response_date.date : response_date.dateTime

    DateTime.parse(date_time.to_s)
  end
end
