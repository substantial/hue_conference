class HueConference::Schedule

  attr_reader :new_schedule, :old_schedule

  def initialize(room)
    @room = room
    @items = []

    room.calendar.event_callbacks.each do |callback|
      @items << build_schedule_item(callback) unless time_is_in_past(callback.time)
    end
  end

  def sync_with_current_schedule(current_schedule)
    @new_schedule = []
    @old_schedule = []

    @items.each do |item|
      if current_schedule
        found = current_schedule.find{ |s| s.timestamp == item.timestamp }
        found ? current_schedule.delete(found) : create_new_schedule_item(item)
      else
        create_new_schedule_item(item)
      end
    end

    @old_schedule = current_schedule.map(&:id).flatten if current_schedule
  end

  def has_new_items?
    @new_schedule.any?
  end

  def has_old_items?
    @old_schedule.any?
  end

  private

  def build_schedule_item(callback)
    item = OpenStruct.new

    item.timestamp = Digest::MD5.hexdigest("#{callback.time}#{callback.type}")[0..15]
    item.name = "#{@room.name}-#{item.timestamp}"
    item.light_id = @room.find_light(callback.light).id
    item.command = callback.command
    item.time = callback.time.iso8601.chomp('Z')

    item
  end

  def create_new_schedule_item(item)
    @new_schedule << item
  end

  def time_is_in_past(time)
    time <= Time.now
  end
end
