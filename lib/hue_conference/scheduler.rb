require 'ruhue'

class HueConference::Scheduler

  attr_reader :client, :rooms

  def initialize(client, rooms)
    @client = client
    @rooms = rooms
  end

  def schedule_rooms
    response = []

    @rooms.each do |room|
      if room.has_upcoming_event?
        schedule = HueConference::Schedule.new(room)

        new_schedule = []
        schedule.items.each do |item|
          name_array = item.name.split('-')
          room_name = name_array.first
          timestamp = name_array.last

          if current_schedule.has_key?(room_name)
            room_schedule = current_schedule[room_name]
            if room_scheudle.includes?(timstamp)
              room_scheule.pop(timestamp)
            else
              new_schedule << item
            end
          end
          room_schedule.ids.each(&:method(delete_schedule))
          new_schedule.each(&:method(create_schedule))
          #response << create_schedule(item)
        end
      else
        response << "Nothing to schedule"
      end
    end

    response
  end

  def current_schedule
    schedule_hash = {}

    all_schedules.each do |id, hash|
      name_array = hash['name'].split('-')
      room_name = name_array.first
      timestamp = name_array.last

      room_hash = { timestamp => id }

      if schedule_hash.has_key?(room_name)
        schedule_hash[room_name] << room_hash
      else
        schedule_hash[room_name] = [room_hash]
      end
    end
    schedule_hash
  end

  def all_schedules
    @client.get("/schedules").data
  end

  def find_schedule(id)
    @client.get("/schedules/#{id}")
  end

  def delete_all_schedules
    all_schedules.keys.each(&method(:delete))
  end

  private

  def create_schedule(schedule)
    write(schedule)
    schedule.name
  end

  def write(schedule)
    options = {
      "name" => schedule.name,
      "command" => {
        "address" => "/api/substantial/lights/#{schedule.light_id}/state",
      "method" => "PUT",
      "body" => schedule.command
      },
      "time" => schedule.time
    }
    response = @client.post("/schedules", options)
    response.data
  end

  def delete(id)
    response = @client.delete("/schedules/#{id}")
    response.data
  end
end
