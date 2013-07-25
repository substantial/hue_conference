class HueConference::Event

  attr_reader :start_date, :end_date, :name

  def initialize(google_events_response)
    @name = google_events_response.summary

    @start_date = convert_date_to_time(google_events_response.start)
    @end_date = convert_date_to_time(google_events_response.end)
  end

  def started?
    @start_date < Time.now.utc
  end

  private

  def convert_date_to_time(response_date)
    date = response_date.dateTime.nil? ? response_date.date : response_date.dateTime

    Time.parse(date.to_s).utc
  end
end
