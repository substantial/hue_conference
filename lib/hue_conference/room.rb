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

  def event_starting
    instance_eval &@event_starting_callback if @event_starting_callback.respond_to?(:to_proc)
  end

  def event_ending
    instance_eval &@event_ending_callback if @event_ending_callback.respond_to?(:to_proc)
  end

  def next_start_time
    calendar.next_event.start_time
  end

  def next_end_time
    calendar.next_event.end_time
  end
end

