require 'hue_conference/room'

class HueConference::Schedule

  attr_reader :room, :items

  def initialize(room)
    @room = room
    @items = room.next_event.callbacks.map{ |callback| build_schedule_item(callback) }
  end

  private

  def build_schedule_item(callback)
    name = "#{@room.name}-#{callback[:time].strftime("%m%d%H%M")}"
    id = @room.find_light(callback[:light]).id
    command = callback[:command]
    time = callback[:time].iso8601.chomp('Z')

    {
      "name" => name,
      "command" => {
        "address" => "/api/substantial/lights/#{id}/state",
        "method" => "PUT",
        "body" => command
      },
      "time" => time
    }
  end
end
