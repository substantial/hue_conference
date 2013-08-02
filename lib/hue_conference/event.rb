class HueConference::Event

  attr_reader :starting_time, :ending_time, :name, :callbacks

  DEFAULT_CALLBACKS = %w(starting ending)

  def initialize(google_events_response)
    @name = google_events_response.summary.downcase.gsub(/\s/, '_')

    @starting_time = convert_date_to_time(google_events_response.start)
    @ending_time = convert_date_to_time(google_events_response.end)

    @callbacks = DEFAULT_CALLBACKS.map{ |callback| send(callback) }
  end

  def started?
    @starting_time < Time.now.utc
  end

  private

  def convert_date_to_time(response_date)
    date = response_date.dateTime.nil? ? response_date.date : response_date.dateTime

    Time.parse(date.to_s).utc
  end

  private

  def starting
    {
      type: 'starting',
      light:'outdoor',
      time: @starting_time,
      command: { 'on' => true }
    }
  end

  def ending
    {
      type: 'ending',
      light: 'outdoor',
      time: @ending_time,
      command: { 'on' => false }
    }
  end
end
