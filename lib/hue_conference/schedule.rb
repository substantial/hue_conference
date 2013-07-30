require 'hue_conference/room'

class HueConference::Schedule

  def initialize(event, room)
    @event = event
    @room = room
  end

  def build
    schedule = {}
    items = []

    room_name = @room.name.downcase.gsub(/\s+/, '')
    schedule[:title] = room_name

    @event.callbacks.each do |callback|
      name = "#{room_name}-#{callback[:name]}_#{callback[:type]}"
      id = @room.find_light(callback[:light]).id
      command = callback[:command]
      time = callback[:time].iso8601.chomp('Z')

      items << {
        "name" => name,
        "command" => {
          "address" => "/api/substantial/lights/#{id}/state",
          "method" => "PUT",
          "body" => command
        },
        "time" => time
      }
    end
    schedule[:items] = items

    schedule
  end

  private

  def room_name_timestamp
    starting = @event.starting_time.strftime("%m%d%H%M")
    ending = @event.ending_time.strftime("%m%d%H%M")

    "#{name}-#{starting}#{ending}"
  end

end
