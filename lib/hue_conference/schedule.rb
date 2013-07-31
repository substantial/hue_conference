require 'hue_conference/room'

class HueConference::Schedule

  attr_reader :items, :room_name

  def initialize(event, room)
    @room_name = room.name
    @items = []

    build_schedule(event, room) if room.next_event
  end

  def build_schedule(event, room)
    event.callbacks.each do |callback|
      name = "#{@room_name}-#{callback[:time].strftime("%m%d%H%M")}"
      id = room.find_light(callback[:light]).id
      command = callback[:command]
      time = callback[:time].iso8601.chomp('Z')

      @items << {
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
end
