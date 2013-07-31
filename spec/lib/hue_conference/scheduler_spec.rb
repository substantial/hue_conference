require "spec_helper"

describe HueConference::Scheduler do
  let(:hue_client) { double }
  let(:rooms) { double }
  let(:all_schedules) {
    {
      "2" => {"name" => "testroomone-10101010"},
      "3" => {"name" => "testroomone-10101020"},
      "4" => {"name" => "testroomtwo-10101100"},
      "5" => {"name" => "testroomtwo-10101200"}
    }
  }
  let(:room_one_starting) { {'10101010' => '2'} }
  let(:room_one_ending) { {'10101020' => '3'} }
  let(:room_two_starting) { {'10101100' => '4'} }
  let(:room_two_ending) { {'10101200' => '5'} }
  let(:current_schedule) {
    {
      'testroomone' => [room_one_starting, room_one_ending],
      'testroomtwo' => [room_two_starting, room_two_ending]
    }
  }

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
    let(:name) { 'testroomone-10101010' }
    let(:item) { double(name: name) }
    let(:schedule) { double(items: [item]) }
    let(:room) { double(has_upcoming_event?: true, schedule: schedule) }
    let(:rooms) { [room] }

    before do
      scheduler.stub(:write)
    end

    context "when a room has an upcoming event" do

      let(:scheduler) { HueConference::Scheduler.new(hue_client, rooms) }

      before do
        HueConference::Schedule.stub(:new) { schedule }
      end

      context "when the room is in the current schedule" do

        before do
          scheduler.stub(:current_schedule) { current_schedule }
        end

        it "should only schedule the changed events" do
          scheduler.should_not_receive(:write)
          scheduler.schedule_rooms
        end
      end

      it "should create a new schedule" do
        scheduler.rooms.each do |room|
          HueConference::Schedule.should_receive(:new).with(room)
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

    context "when a room has no upcoming events" do

      let(:scheduler) { HueConference::Scheduler.new(hue_client, rooms) }

      before do
        room.stub(:has_upcoming_event?) { false }
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

  describe "#delete_all_schedules" do

    let(:scheduler) { HueConference::Scheduler.new(hue_client, rooms) }

    before do
      hue_client.stub(:delete) { double(data: 'response') }
      scheduler.stub(:all_schedules) { all_schedules }
    end

    it "should delete all hue schedules" do
      hue_client.should_receive(:delete).with("/schedules/2")
      hue_client.should_receive(:delete).with("/schedules/3")
      scheduler.delete_all_schedules
    end
  end

  describe "#current_schedule" do
    let(:scheduler) { HueConference::Scheduler.new(hue_client, rooms) }

    before do
      scheduler.stub(:all_schedules) { all_schedules }
    end

    it "should return a current schedule object" do
      scheduler.current_schedule.should == current_schedule
    end
  end
end
