require 'ostruct'
require 'hue_conference/room'

class HueConference::Schedule

  attr_reader :room, :items

  def initialize(room)
    @room = room
    @items = room.event.callbacks.map do |callback|
      build_schedule_item(callback)
    end
  end

  private

  def build_schedule_item(callback)
    item = OpenStruct.new

    item.timestamp = callback.time.strftime("%m%d%H%M")
    item.name = "#{@room.name}-#{item.timestamp}"
    item.light_id = @room.find_light(callback.light).id
    item.command = callback.command
    item.time = callback.time.iso8601.chomp('Z')

    item
  end
end
