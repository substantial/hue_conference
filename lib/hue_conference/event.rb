class HueConference::Event
  include Comparable

  attr_reader :start_date, :end_date

  def initialize(google_events_response)
    @start_date = DateTime.parse(google_events_response["start"]["dateTime"])
    @end_date = DateTime.parse(google_events_response["end"]["dateTime"])
  end

  def <=>(other)
    other.start_date <=> @start_date
  end
end
