require "spec_helper"

describe HueConference::Scheduler do
  let(:client) { double }
  let(:rooms) { double }
  let(:room_name_one) { "testroomone" }
  let(:room_name_two) { "testroomtwo" }
  let(:all_schedules) {
    {
      "2" => {"name" => "#{room_name_one}-10101010"},
      "3" => {"name" => "#{room_name_one}-10101020"},
      "4" => {"name" => "#{room_name_two}-10101100"},
      "5" => {"name" => "#{room_name_two}-10101200"}
    }
  }
  let(:room_one_starting) { create_schedule_item('10101010', '2') }
  let(:room_one_ending) { create_schedule_item('10101020', '3') }
  let(:room_two_starting) { create_schedule_item('10101100', '4') }
  let(:room_two_ending) { create_schedule_item('10101200', '5') }

  let(:current_schedule) {
    {
      "#{room_name_one}" => [room_one_starting, room_one_ending],
      "#{room_name_two}" => [room_two_starting, room_two_ending]
    }
  }

  describe "#initialize" do
    it "should require a RueHue client" do
      expect { HueConference::Scheduler.new }.to raise_error ArgumentError
    end

    it "should require the rooms" do
      expect { HueConference::Scheduler.new(client) }.to raise_error ArgumentError
    end

    it "should set the client instance variable" do
      scheduler = HueConference::Scheduler.new(client, rooms)
      scheduler.instance_variable_get(:@client).should == client
    end

    it "should set the rooms instance variable" do
      scheduler = HueConference::Scheduler.new(client, rooms)
      scheduler.instance_variable_get(:@rooms).should == rooms
    end
  end

  describe "#schedule_rooms" do
    let(:scheduler) { HueConference::Scheduler.new(client, rooms) }

    before do
      room.stub_chain(:calendar, :sync_events!)
      scheduler.stub(:write)
      scheduler.stub(:delete)
    end

    context "when a room has an upcoming event" do
      let(:room) { double(has_upcoming_event?: true, name: 'testroomone') }
      let(:rooms) { [room] }

      context "when both schedules match" do
        let(:schedule) { double(sync_with_current_schedule: true,
                                has_old_items?: false,
                                has_new_items?: false) }


        before do
          scheduler.stub(:current_schedule) { current_schedule }
          HueConference::Schedule.stub(:new) { schedule }
        end

        it "should create a schedule" do
          HueConference::Schedule.should_receive(:new).with(room, current_schedule[room.name])
          scheduler.schedule_rooms
        end

        it "should sync with current schedule" do
          schedule.should_receive(:sync_with_current_schedule)
          scheduler.schedule_rooms
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

      context "when the room schedule has new items" do
        let(:new_schedule) { [double.as_null_object] }
        let(:schedule) { double(sync_with_current_schedule: true,
                                has_old_items?: false,
                                has_new_items?: true,
                                new_schedule: new_schedule) }

        before do
          scheduler.stub(:current_schedule) { current_schedule }
          HueConference::Schedule.stub(:new) { schedule }
        end

        it "should write each schedule item to the hue" do
          new_schedule.each do |schedule|
            scheduler.should_receive(:write).with(schedule)
          end
          scheduler.schedule_rooms
        end

        it "should not delete any schedules" do
          scheduler.should_not_receive(:delete)
          scheduler.schedule_rooms
        end
      end

      context "when the schedule has old items" do
        let(:old_schedule) { %w(1 2) }
        let(:schedule) { double(sync_with_current_schedule: true,
                                has_old_items?: true,
                                has_new_items?: false,
                                old_schedule: old_schedule) }

        before do
          scheduler.stub(:current_schedule) { current_schedule }
          HueConference::Schedule.stub(:new) { schedule }
        end

        it "should delete all current schedules that are different" do
          old_schedule.each do |id|
            scheduler.should_receive(:delete).with(id)
          end
          scheduler.schedule_rooms
        end

        it "should not write any schedules" do
          scheduler.should_not_receive(:write).with(schedule)
          scheduler.schedule_rooms
        end
      end
    end

    context "when a room has no upcoming events" do
      let(:room) { double(has_upcoming_event?: false, name: room_name_one) }

      let(:scheduler) { HueConference::Scheduler.new(client, [room]) }

      it "should not write any schedules" do
        scheduler.should_not_receive(:write)
        scheduler.schedule_rooms
      end

      it "should not write any schedules" do
        scheduler.should_not_receive(:delete)
        scheduler.schedule_rooms
      end
    end
  end

  describe "#all_schedules" do
    let(:schedules) { {'1' => 'something' } }
    let(:response) { double(data: schedules) }

    let(:scheduler) { HueConference::Scheduler.new(client, rooms) }

    before do
      client.stub(:get) { response }
    end

    it "should make a request to the client" do
      client.should_receive(:get).with("/schedules")
      scheduler.all_schedules
    end

    it "should return all the hue schedules" do
      scheduler.all_schedules.should == schedules
    end
  end

  describe "#find_schedule" do

    let(:schedule) { 'schedule details' }
    let(:schedule_id) { 2 }

    let(:scheduler) { HueConference::Scheduler.new(client, rooms) }

    before do
      client.stub(:get) { schedule }
    end

    it "should make a request to the client for a specific schedule" do
      client.should_receive(:get).with("/schedules/#{schedule_id}")
      scheduler.find_schedule(schedule_id)
    end

    it "should return the schedule details" do
      scheduler.find_schedule(schedule_id).should == schedule
    end
  end

  describe "#delete_all_schedules" do

    let(:scheduler) { HueConference::Scheduler.new(client, rooms) }

    before do
      client.stub(:delete) { double(data: 'response') }
      scheduler.stub(:all_schedules) { all_schedules }
    end

    it "should delete all hue schedules" do
      client.should_receive(:delete).with("/schedules/2")
      client.should_receive(:delete).with("/schedules/3")
      scheduler.delete_all_schedules
    end
  end

  describe "#current_schedule" do
    let(:scheduler) { HueConference::Scheduler.new(client, rooms) }

    before do
      scheduler.stub(:all_schedules) { all_schedules }
    end

    it "should return a current schedule object" do
      scheduler.current_schedule.should == current_schedule
    end
  end

  def create_schedule_item(timestamp, id)
    OpenStruct.new(id: id, timestamp: timestamp)
  end
end
