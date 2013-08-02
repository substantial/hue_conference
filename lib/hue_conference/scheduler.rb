require 'ruhue'

class HueConference::Scheduler

  attr_reader :client, :rooms

  def initialize(client, rooms)
    @client = client
    @rooms = rooms
  end

  def schedule_rooms
    response = []
    #delete_current_schedule

    @rooms.each do |room|
      if room.has_upcoming_event?
        schedule = HueConference::Schedule.new(room)

        schedule.items.each do |item|
          response << create_schedule(item)
        end
      else
        response << "Nothing to schedule"
      end
    end

    response
  end

  def all_schedules
    @client.get("/schedules").data
  end

  def find_schedule(id)
    @client.get("/schedules/#{id}")
  end

  private

  def create_schedule(schedule)
    write(schedule)
    schedule['name']
  end

  def delete_current_schedule
    all_schedules.each { |id, name| delete(id) }
  end

  def write(schedule)
    response = @client.post("/schedules", schedule)
    puts response.data
  end

  def delete(id)
    response = @client.delete("/schedules/#{id}")
    puts response.data
  end
end
