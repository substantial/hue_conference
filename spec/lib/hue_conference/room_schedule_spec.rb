require 'spec_helper'

describe HueConference::RoomSchedule do

  describe "#initialize" do
    let(:schedule) { double }
    let(:current_schedule) { double }
    let(:room) { double }

    let(:room_schedule) { HueConference::RoomSchedule.new(room, current_schedule) }

    before do
      HueConference::Schedule.stub(:new) { schedule }
    end

    it "should require a room" do
      expect { HueConference::RoomSchedule.new }.to raise_error ArgumentError
    end

    it "should require a current_schedule" do
      expect { HueConference::RoomSchedule.new(room) }.to raise_error ArgumentError
    end

    it "should have a current schedule" do
      room_schedule.current_schedule.should == current_schedule
    end

    it "should create a schedule" do
      HueConference::Schedule.should_receive(:new).with(room)
      room_schedule
    end

    it "should have a schedule" do
      room_schedule.schedule.should == schedule
    end

    it "should have a new schedule array" do
      room_schedule.new_schedule.should == []
    end

    it "should have an old schedule array" do
      room_schedule.old_schedule.should == []
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
        let(:room) { double }

        let(:room_schedule) { HueConference::RoomSchedule.new(room, current_schedule) }

        before do
          HueConference::Schedule.stub(:new) { schedule }
        end

        it "should not create a new schedule" do
          room_schedule.build
          room_schedule.new_schedule.should == []
        end

        it "should remove the schedule from the current_schedule queue" do
          room_schedule.build
          room_schedule.current_schedule.should == []
        end
      end

      context "and the scheduled event is not in the current schedule" do
        let(:old_schedule) { [2] }
        let(:item) { double(timestamp: '20202020') }
        let(:schedule) { double(items: [item]) }
        let(:new_schedule) { [item] }
        let(:current_scheduled_event) { OpenStruct.new(id: 2, timestamp: '10101010') }
        let(:current_schedule) { [current_scheduled_event] }
        let(:room) { double }

        let(:room_schedule) { HueConference::RoomSchedule.new(room, current_schedule) }

        before do
          HueConference::Schedule.stub(:new) { schedule }
        end

        it "should create a new schedule" do
          room_schedule.build
          room_schedule.new_schedule.should == new_schedule
        end

        it "should add the scheduled event to the old schedule array" do
          room_schedule.build
          room_schedule.old_schedule.should == old_schedule
        end
      end

    end

    context "when there is no current room schedule" do
      let(:new_schedule) { [item] }
      let(:item) { double('schedule item') }
      let(:schedule) { double(items: [item]) }
      let(:current_schedule) { [] }
      let(:room) { double }

      let(:room_schedule) { HueConference::RoomSchedule.new(room, current_schedule) }

      before do
        HueConference::Schedule.stub(:new) { schedule }
      end

      it "should create a new schedule" do
        room_schedule.build
        room_schedule.new_schedule.should == new_schedule
      end
    end
  end

  describe "#new_schedule?" do
    let(:room_schedule) { HueConference::RoomSchedule.new(double, double) }

    before do
      HueConference::Schedule.stub(:new) { double }
    end

    it "should be true if there are new schedules" do
      room_schedule.instance_variable_set(:@new_schedule, [double])
      room_schedule.new_schedule?.should == true
    end

    it "should be true when there are no new schedules" do
      room_schedule.instance_variable_set(:@new_schedule, [])
      room_schedule.new_schedule?.should == false
    end
  end

  describe "#old_schedule?" do
    let(:room_schedule) { HueConference::RoomSchedule.new(double, double) }

    before do
      HueConference::Schedule.stub(:new) { double }
    end

    it "should be true if there are old schedules" do
      room_schedule.instance_variable_set(:@old_schedule, [double])
      room_schedule.old_schedule?.should == true
    end

    it "should be true when there are no old schedules" do
      room_schedule.instance_variable_set(:@old_schedule, [])
      room_schedule.old_schedule?.should == false
    end
  end
end
