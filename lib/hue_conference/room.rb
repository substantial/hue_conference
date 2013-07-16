class HueConference::Room

  attr_reader :name, :lights

  def initialize(name='')
    @name = name
    @lights = []
  end

  def turn_off_lights
    @lights.each(&:off)
  end

  def turn_on_lights
    @lights.each(&:on)
  end
end
