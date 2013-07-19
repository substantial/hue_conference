class HueConference::Event
  include Comparable

  attr_reader :start_date, :end_date

  def initialize(google_events_response)
    @start_date = DateTime.parse(google_events_response.start.dateTime.to_s)
    @end_date = DateTime.parse(google_events_response.end.dateTime.to_s)
  end

  def <=>(other)
    other.start_date <=> @start_date
  end
end
