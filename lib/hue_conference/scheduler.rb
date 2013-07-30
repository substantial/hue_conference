require 'ruhue'

class HueConference::Scheduler

  attr_reader :client, :rooms, :current_schedule

  def initialize(client, rooms)
    @client = client
    @rooms = rooms
    @current_schedule = []
  end

  def schedule_rooms
    @rooms.each do |room|
      schedule = room.update_schedule
      if schedule
        create_schedule(schedule[:items])
      end
    end
    'rooms scheduled'
  end

  def update_current_schedule
    all_schedules.each do |id, hash|
      @current_schedule[id] = hash['name']
    end unless all_schedules.empty?
  end

  def all_schedules
    @client.get("/schedules").data
  end

  def find_schedule(id)
    @client.get("/schedules/#{id}")
  end

  private

  def create_schedule(schedule)
    schedule.each { |s| write(s) }
  end

  def write(schedule)
    response = @client.post("/schedules", schedule)
    puts response.data
  end
end
