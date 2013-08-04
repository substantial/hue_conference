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
  let(:room_one_starting) { current_schedule_item('10101010', '2') }
  let(:room_one_ending) { current_schedule_item('10101020', '3') }
  let(:room_two_starting) { current_schedule_item('10101100', '4') }
  let(:room_two_ending) { current_schedule_item('10101200', '5') }

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

    before do
      scheduler.stub(:write)
      scheduler.stub(:delete)
      room.stub_chain(:calendar, :sync_events!)
    end

    context "when a room has an upcoming event" do

      context "when the room schedule matches current schedule" do
        let(:schedule) { double(has_old_items?: false,
                                has_new_items?: false) }
        let(:room) { double(has_upcoming_event?: true, name: 'testroomone') }
        let(:rooms) { [room] }

        let(:scheduler) { HueConference::Scheduler.new(hue_client, rooms) }

        before do
          scheduler.stub(:current_schedule) { current_schedule }
          HueConference::Schedule.stub_chain(:new, :build) { schedule }
        end

        it "should not delete a schedule" do
          scheduler.should_not_receive(:write)
          scheduler.schedule_rooms
        end

        it "should not create a schedule" do
          scheduler.should_not_receive(:write)
          scheduler.schedule_rooms
        end
      end

      context "when the room schedule is different from the current schedule" do
        let(:old_schedule) { %w(1 2) }
        let(:new_schedule) { [double.as_null_object] }
        let(:schedule) { double(has_old_items?: true,
                                has_new_items?: true,
                                old_schedule: old_schedule,
                                new_schedule: new_schedule,
                                log: 'schedule log') }
        let(:room) { double(has_upcoming_event?: true, name: 'testroomone') }
        let(:rooms) { [room] }

        let(:scheduler) { HueConference::Scheduler.new(hue_client, rooms) }

        before do
          scheduler.stub(:current_schedule) { current_schedule }
          HueConference::Schedule.stub_chain(:new, :build) { schedule }
        end

        it "should delete all current schedules that are different" do
          old_schedule.each do |id|
            scheduler.should_receive(:delete).with(id)
          end
          scheduler.schedule_rooms
        end

        it "should write each schedule item to the hue" do
          new_schedule.each do |schedule|
            scheduler.should_receive(:write).with(schedule)
          end
          scheduler.schedule_rooms
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

  def current_schedule_item(timestamp, id)
    OpenStruct.new(id: id, timestamp: timestamp)
  end
end
