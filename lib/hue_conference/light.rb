class HueConference::Light
  attr_reader :name, :id
  attr_accessor :client

  def initialize(id, properties = {})
    @id = id
    @name = properties['name']
  end

  def turn_on
    @client.put("/lights/#{id}/state", on: true)
  end

  def turn_off
    @client.put("/lights/#{id}/state", on: false)
  end

end
