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
      new_schedule = []

      if room.has_upcoming_event?
        schedule = HueConference::Schedule.new(room)

        room_name = room.name

        current_room_schedule = current_schedule[room_name]

        schedule.items.each do |item|

          if current_room_schedule
            result = current_room_schedule.find do |hash|
              hash.include?(item.timestamp)
            end

            if result
              current_room_schedule.delete(result)
            else
              new_schedule << item
            end

          else
            new_schedule << item
          end

          response << item.name
        end
        ids = current_room_schedule.map{ |hash| hash.map{ |k,v| v.to_i} }.flatten
        ids.each{ |id| delete(id) } unless ids.empty?
        new_schedule.each{ |schedule| write(schedule) } unless new_schedule.empty?
      else
        response << "Nothing scheduled for #{room.name}"
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
