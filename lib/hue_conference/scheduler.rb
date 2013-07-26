require 'ruhue'

class HueConference::Scheduler

  attr_reader :client, :rooms

  def initialize(client, rooms)
    @client = client
    @rooms = rooms
  end

  def schedule_rooms
    success = []
    @rooms.each do |room|
      if room.next_event
        schedule_event(room, event_starting)
        schedule_event(room, event_ending)
        success << room.name
      else
        success = ['No events to schedule']
      end
    end
    success
  end

  private

  def event_starting
    {
      start: true,
      command: {
        'on' => true
      }
    }
  end

  def event_ending
    {
      start: false,
      command: {
        'on' => false
      }
    }
  end

  def schedule_event(room, action)
    event = room.next_event
    light = room.lights.first

    state = action[:start] ? 'Start' : 'End'
    date = action[:start] ? :start_date : :end_date

    params = {
      "name" => "#{state}: #{event.name}",
      "command" => {
        "address" => "/api/substantial/lights/#{light.id}/state",
        "method" => "PUT",
        "body" => action[:command]
      },
      "time" => event.send(date).iso8601.chomp('Z')
    }
    write_event(params)
  end

  def write_event(params)
    @client.post("/schedules", params)
  end
end
