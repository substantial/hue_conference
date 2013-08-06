class HueConference::Schedule

  attr_reader :room, :current_schedule, :items, :new_schedule, :old_schedule

  def initialize(room, current_schedule)
    @room = room
    @current_schedule = current_schedule
    @items = []
    @new_schedule = []
    @old_schedule = []

    room.event.callbacks.map do |callback|
      @items << build_schedule_item(callback)
    end
  end

  def build
    @items.each do |item|
      if @current_schedule
        found = find_in_current_schedule(item)
        found ? @current_schedule.delete(found) : @new_schedule << item
      else
        @new_schedule << item
      end

      @old_schedule = @current_schedule.map(&:id).flatten if @current_schedule
    end
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

    item.timestamp = callback.time.strftime("%m%d%H%M")
    item.name = "#{@room.name}-#{item.timestamp}"
    item.light_id = @room.find_light(callback.light).id
    item.command = callback.command
    item.time = callback.time.iso8601.chomp('Z')

    item
  end

  def create_schedule(item)
    @new_schedule << item
  end

  def find_in_current_schedule(item)
    @current_schedule.find do |schedule|
      schedule.timestamp == item.timestamp
    end
  end
end
