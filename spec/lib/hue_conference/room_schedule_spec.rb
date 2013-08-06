require 'spec_helper'

describe HueConference::RoomSchedule do

  context "when a room has an upcoming event" do

    context "when the room schedule is the same as the current schedule" do
      let(:room_name) { 'testroomone' }
      let(:timestamp) { '10101010' }
      let(:name) { "#{room_name}-#{timestamp}" }
      let(:item) { double(name: name, timestamp: timestamp) }
      let(:schedule) { double(items: [item]) }
      let(:room) { double(has_upcoming_event?: true, schedule: schedule, name: room_name) }
      let(:rooms) { [room] }

      let(:scheduler) { HueConference::Scheduler.new(hue_client, rooms) }

      before do
        HueConference::Schedule.stub(:new) { schedule }
        scheduler.stub(:current_schedule) { current_schedule }
      end

      it "should not create a schedule" do
        scheduler.should_not_receive(:write)
        scheduler.schedule_rooms
      end
    end

    context "when the room schedule is different from the current schedule" do
      let(:room_name) { 'testroomone' }
      let(:timestamp) { '10101099' }
      let(:name) { "#{room_name}-#{timestamp}" }
      let(:item) { double(name: name, timestamp: timestamp) }
      let(:schedule) { double(items: [item]) }
      let(:room) { double(has_upcoming_event?: true, schedule: schedule, name: room_name) }
      let(:rooms) { [room] }

      let(:scheduler) { HueConference::Scheduler.new(hue_client, rooms) }

      before do
        HueConference::Schedule.stub(:new) { schedule }
        scheduler.stub(:current_schedule) { current_schedule }
      end

      it "should create a new schedule" do
        scheduler.rooms.each do |room|
          HueConference::Schedule.should_receive(:new).with(room)
        end
        scheduler.schedule_rooms
      end

      it "should delete all current schedules that are different" do
        current_schedule[room_name].each do |schedule|
          id = schedule.values.first.to_i
          scheduler.should_receive(:delete).with(id)
        end
        scheduler.schedule_rooms
      end

      it "should write each schedule item to the hue" do
        schedule.items.each do |item|
          scheduler.should_receive(:write).with(item)
        end
        scheduler.schedule_rooms
      end

      it "should return an array of scheduled items" do
        scheduler.schedule_rooms.should == [name]
      end
    end
  end

  context "when a room has no upcoming events" do
    let(:room) { double(has_upcoming_event?: false, name: 'roomname') }

    let(:scheduler) { HueConference::Scheduler.new(hue_client, [room]) }

    it "should not write any schedule to the hue" do
      scheduler.should_not_receive(:write)
      scheduler.schedule_rooms
    end

    it "should return an array of scheduled callbacks" do
      scheduler.schedule_rooms.should == ['Nothing scheduled for roomname']
    end
  end
end
