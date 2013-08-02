require "spec_helper"

describe HueConference::Schedule do

  describe "#initialize" do
    let(:callback) {
      {
        light: 'outdoor',
        time: Time.new(2010, 10, 10, 10, 10),
        command: { 'on' => true }
      }
    }
    let(:callbacks) { [callback] }

    let(:event) { double(callbacks: callbacks) }
    let(:room_name) { 'testroom' }
    let(:light) { double(id: 1) }
    let(:room) { double(next_event: event, name: room_name, find_light: light) }

    let(:schedule) { HueConference::Schedule.new(room) }

    it "should require a room" do
      expect { HueConference::Schedule.new }.to raise_error ArgumentError
    end

    it "should have a room" do
      schedule.room.should == room
    end

    it "should build an array of formatted schedule items" do

      schedule_formatted_response = {
        "name" => 'testroom-10101010',
        "command" => {
          "address" => "/api/substantial/lights/1/state",
          "method" => "PUT",
          "body" => { 'on' => true }
        },
        "time" => "2010-10-10T10:10:00-07:00"
      }
      schedule.items.should == [schedule_formatted_response]
    end
  end
end
