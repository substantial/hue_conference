require 'ostruct'
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
      room.calendar.sync_events!

      if room.has_upcoming_event?
        current_room_schedule = current_schedule[room.name]
        schedule = HueConference::Schedule.new(room, current_room_schedule).build

        delete_schedules(schedule.old_schedule) if schedule.old_schedule?

        write_schedules(schedule.new_schedule) if schedule.new_schedule?
      end

    end

    "Schedule Created"
  end

  def current_schedule
    schedule_hash = {}

    all_schedules.each do |id, hash|
      name_array = hash['name'].split('-')
      room_name = name_array.first
      timestamp = name_array.last

      room_schedule = OpenStruct.new(id: id, timestamp: timestamp)

      if schedule_hash.has_key?(room_name)
        schedule_hash[room_name] << room_schedule
      else
        schedule_hash[room_name] = [room_schedule]
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

  def write_schedules(schedules)
    unless schedules.empty?
      schedules.each{ |schedule| write(schedule) }
    end
  end

  def delete_schedules(schedules)
    unless schedules.empty?
      schedules.each{ |schedule| delete(schedule) }
    end
  end
end
