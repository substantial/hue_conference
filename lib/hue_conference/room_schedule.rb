class HueConference::RoomSchedule

  attr_reader :current_schedule, :schedule, :new_schedule, :old_schedule

  def initialize(room, current_schedule)
    @current_schedule = current_schedule
    @schedule = HueConference::Schedule.new(room)
    @new_schedule = []
    @old_schedule = []
  end

  def build
    @schedule.items.each do |item|

      if @current_schedule
        found = find_in_current_schedule(item)
        found ? @current_schedule.delete(found) : @new_schedule << item
      else
        @new_schedule << item
      end

      @old_schedule = @current_schedule.map(&:id).flatten if @current_schedule
    end

    self
  end

  def new_schedule?
    @new_schedule.any?
  end

  def old_schedule?
    @old_schedule.any?
  end

  private

  def create_schedule(item)
    @new_schedule << item
  end

  def find_in_current_schedule(item)
    @current_schedule.find do |schedule|
      schedule.timestamp == item.timestamp
    end
  end
end
