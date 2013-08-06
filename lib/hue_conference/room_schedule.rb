class HueConference::RoomSchedule

  def initialize(room, current_schedule)

  end


 # def build
 #   schedule = HueConference::Schedule.new(room)


 #   room_name = room.name

 #   #current_room_schedule = current_schedule[room_name]

 #   schedule.items.each do |item|

 #     if current_room_schedule
 #       result = current_room_schedule.find do |hash|
 #         hash.include?(item.timestamp)
 #       end

 #       if result
 #         current_room_schedule.delete(result)
 #       else
 #         new_schedule << item
 #       end

 #     else
 #       new_schedule << item
 #     end

 #     response << item.name
 #   end

 #   ids = current_room_schedule.map{ |hash| hash.map{ |k,v| v.to_i} }.flatten

 # end
end
