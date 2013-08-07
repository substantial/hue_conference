require 'spec_helper'

describe HueConference::Schedule do

  describe "#initialize" do

    let(:current_schedule) { double }
    let(:callback) {
      OpenStruct.new({
        light: 'outdoor',
        time: Time.new(2010, 10, 10, 10, 10),
        command: { 'on' => true }
      })
    }
    let(:event) { double(callbacks: [callback]) }
    let(:light) { double(id: 1) }
    let(:room_name) { 'testroom' }
    let(:room) { double(event: event, name: room_name, find_light: light) }

    let(:schedule) { HueConference::Schedule.new(room, current_schedule) }

    it "should require a room" do
      expect { HueConference::Schedule.new }.to raise_error ArgumentError
    end

    it "should require a current_schedule" do
      expect { HueConference::Schedule.new(room) }.to raise_error ArgumentError
    end

    it "should have a current schedule" do
      schedule.current_schedule.should == current_schedule
    end

    it "should have a room" do
      schedule.room.should == room
    end

    it "should have a new schedule array" do
      schedule.new_schedule.should == []
    end

    it "should have an old schedule array" do
      schedule.old_schedule.should == []
    end

    it "should build an array of schedule items from callbacks" do
      item = OpenStruct.new(
        timestamp: '1010101000',
        name: 'testroom-1010101000',
        light_id: 1,
        command: { 'on' => true },
        time: '2010-10-10T10:10:00-07:00'
      )

      schedule.items.should == [item]
    end
  end

  describe "#build" do

    context "when there is a current schedule for the room" do

      context "and the scheduled event is in the current schedule" do
        let(:timestamp) { '10101010' }
        let(:item) { double(timestamp: timestamp) }
        let(:schedule) { double(items: [item]) }
        let(:new_schedule) { [item] }
        let(:current_scheduled_event) { OpenStruct.new(id: 2, timestamp: timestamp) }
        let(:current_schedule) { [current_scheduled_event] }
        let(:room) { double.as_null_object }

        let(:schedule) { HueConference::Schedule.new(room, current_schedule) }

        before do
          schedule.instance_variable_set(:@items, [item])
        end

        it "should not create a new schedule" do
          schedule.build
          schedule.new_schedule.should == []
        end

        it "should remove the schedule from the current_schedule queue" do
          schedule.build
          schedule.current_schedule.should == []
        end

        it "should return the schedule" do
          schedule.build.should == schedule
        end
      end

      context "and the scheduled event is not in the current schedule" do
        let(:old_schedule) { [2] }
        let(:item) { double(timestamp: '20202020') }
        let(:schedule) { double(items: [item]) }
        let(:new_schedule) { [item] }
        let(:current_scheduled_event) { OpenStruct.new(id: 2, timestamp: '10101010') }
        let(:current_schedule) { [current_scheduled_event] }
        let(:room) { double.as_null_object }

        let(:schedule) { HueConference::Schedule.new(room, current_schedule) }

        before do
          schedule.instance_variable_set(:@items, [item])
        end

        it "should create a new schedule" do
          schedule.build
          schedule.new_schedule.should == new_schedule
        end

        it "should add the scheduled event to the old schedule array" do
          schedule.build
          schedule.old_schedule.should == old_schedule
        end
      end

    end

    context "when there is no current room schedule" do
      let(:new_schedule) { [item] }
      let(:item) { double('schedule item') }
      let(:schedule) { double(items: [item]) }
      let(:current_schedule) { [] }
      let(:room) { double.as_null_object }

      let(:schedule) { HueConference::Schedule.new(room, current_schedule) }

      before do
        schedule.instance_variable_set(:@items, [item])
      end

      it "should create a new schedule" do
        schedule.build
        schedule.new_schedule.should == new_schedule
      end
    end
  end

  describe "#has_new_items?" do
    let(:schedule) { HueConference::Schedule.new(double.as_null_object, double) }

    context "when there are new schedules" do
      before do
        schedule.instance_variable_set(:@new_schedule, [double])
      end

      it "should be true" do
        schedule.has_new_items?.should == true
      end
    end

    context "when there are no new schedules" do
      before do
        schedule.instance_variable_set(:@new_schedule, [])
      end

      it "should be false" do
        schedule.has_new_items?.should == false
      end
    end
  end

  describe "#has_old_items?" do
    let(:schedule) { HueConference::Schedule.new(double.as_null_object, double) }

    context "when there are new schedules" do
      before do
        schedule.instance_variable_set(:@old_schedule, [double])
      end

      it "should be true" do
        schedule.has_old_items?.should == true
      end
    end

    context "when there are no new schedules" do
      before do
        schedule.instance_variable_set(:@old_schedule, [])
      end

      it "should be false" do
        schedule.has_old_items?.should == false
      end
    end
  end
end
