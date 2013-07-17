class HueConference::Light
  attr_reader :name, :id
  attr_accessor :client

  def initialize(id, properties = {})
    @id = id
    @name = properties['name']
    @on = true
  end

  def turn_on
   unless on?
    @client.put("/lights/#{id}/state", on: true)
    @on = true
   end
  end

  def turn_off
   if on?
    @client.put("/lights/#{id}/state", on: false)
    @on = false
   end
  end

  def on?
    @on
  end

  def sync!
    light_state = @client.get("/lights/#{id}").data['state']

    @on = light_state['on']
  end

  def toggle
    if on?
      turn_off
    else
      turn_on
    end
  end

end
