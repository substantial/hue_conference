class HueConference::Room

  attr_reader :name
  attr_accessor :lights, :calendar, :event_starting_callback, :event_ending_callback

  def initialize(room_config_hash)
    @name = room_config_hash[:name]
    @lights = []
  end

  def turn_off_lights
    @lights.each(&:off)
  end

  def turn_on_lights
    @lights.each(&:on)
  end

  def find_light(location)
    @lights.select do |light|
      light.location == location
    end.first
  end

  def on_event_start &block
    self.event_starting_callback = block
  end

  def on_event_end &block
    self.event_ending_callback = block
  end

  def event_starting
    @event_starting_callback.call(self) if @event_starting_callback.respond_to?(:call)
  end

  def event_ending
    @event_ending_callback.call(self) if @event_ending_callback.respond_to?(:call)
  end

  def next_start_time
    calendar.next_event.start_date
  end

  def next_end_time
    calendar.next_event.end_date
  end
end

