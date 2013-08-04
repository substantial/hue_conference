class HueConference::Room

  attr_reader :name, :schedule
  attr_accessor :lights, :calendar

  def initialize(room_config_hash)
    @name = room_config_hash["name"].downcase.gsub(/\W+/, '')[0, 20]
    @lights = []
  end

  def has_upcoming_event?
    !event.nil?
  end

  def turn_on_lights
    @lights.each(&:on!)
  end

  def turn_off_lights
    @lights.each(&:off!)
  end

  def find_light(location)
    @lights.select do |light|
      light.location == location
    end.first
  end

  def event
    calendar.current_event
  end

  private

  def create_schedule
    @schedule = HueConference::Schedule.new(next_event, self) if success
  end
end

