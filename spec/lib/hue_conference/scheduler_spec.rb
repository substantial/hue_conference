require "spec_helper"

describe HueConference::Scheduler do

  let(:hue_client) { double }
  let(:rooms) { double }

  describe "#initialize" do
    it "should require a RueHue client" do
      expect { HueConference::Scheduler.new }.to raise_error ArgumentError
    end

    it "should have a RueHue client" do
      scheduler = HueConference::Scheduler.new(hue_client, rooms)
      scheduler.client.should == hue_client
    end

    it "should require the rooms" do
      expect { HueConference::Scheduler.new(hue_client) }.to raise_error ArgumentError
    end

    it "should have rooms" do
      scheduler = HueConference::Scheduler.new(hue_client, rooms)
      scheduler.rooms.should == rooms
    end
  end

  describe "#schedule_rooms" do
    let(:hue_client) { double }
    let(:callback) { double(name: 'room-starting-callback') }
    let(:schedule) { double(callbacks: [callback]) }
    let(:room) { double(update_schedule: schedule) }
    let(:rooms) { [room] }

    before do
      scheduler.stub(:write)
    end

    context "when a room has an upcoming event" do

      let(:scheduler) { HueConference::Scheduler.new(hue_client, rooms) }

      it "should update the schedule for each room" do
        scheduler.rooms.each do |room|
          room.should_receive(:update_schedule)
        end
        scheduler.schedule_rooms
      end

      it "should write each schedule callback to the hue" do
        schedule.callbacks.each do |callback|
          scheduler.should_receive(:write).with(callback)
        end
        scheduler.schedule_rooms
      end

      it "should return an array of scheduled callbacks" do
        scheduler.schedule_rooms.should == ['room-starting-callback']
      end
    end

    context "when a room has no upcoming events" do

      let(:scheduler) { HueConference::Scheduler.new(hue_client, rooms) }

      before do
        room.stub(:update_schedule) { false }
      end

      it "should not write any schedule to the hue" do
        scheduler.should_not_receive(:write)
        scheduler.schedule_rooms
      end

      it "should return an array of scheduled callbacks" do
        scheduler.schedule_rooms.should == ['Nothing to schedule']
      end
    end
  end

  describe "#all_schedules" do
    let(:schedules) { {'1' => 'something' } }
    let(:response) { double(data: schedules) }

    let(:scheduler) { HueConference::Scheduler.new(hue_client, rooms) }

    before do
      hue_client.stub(:get) { response }
    end

    it "should make a request to the client" do
      hue_client.should_receive(:get).with("/schedules")
      scheduler.all_schedules
    end

    it "should return all the hue schedules" do
      scheduler.all_schedules.should == schedules
    end
  end

  describe "#find_schedule" do

    let(:schedule) { 'schedule details' }
    let(:schedule_id) { 2 }

    let(:scheduler) { HueConference::Scheduler.new(hue_client, rooms) }

    before do
      hue_client.stub(:get) { schedule }
    end

    it "should make a request to the client for a specific schedule" do
      hue_client.should_receive(:get).with("/schedules/#{schedule_id}")
      scheduler.find_schedule(schedule_id)
    end

    it "should return the schedule details" do
      scheduler.find_schedule(schedule_id).should == schedule
    end
  end
end
