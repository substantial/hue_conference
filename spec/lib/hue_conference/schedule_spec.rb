require "spec_helper"

describe HueConference::Schedule do

  describe "#initialize" do
    let(:callback) {
      OpenStruct.new({
        light: 'outdoor',
        time: Time.new(2010, 10, 10, 10, 10),
        command: { 'on' => true }
      })
    }
    let(:callbacks) { [callback] }

    let(:event) { double(callbacks: callbacks) }
    let(:room_name) { 'testroom' }
    let(:light) { double(id: 1) }
    let(:room) { double(event: event, name: room_name, find_light: light) }

    let(:schedule) { HueConference::Schedule.new(room) }

    it "should require a room" do
      expect { HueConference::Schedule.new }.to raise_error ArgumentError
    end

    it "should have a room" do
      schedule.room.should == room
    end

    it "should build an array of schedule items from callbacks" do
      item = OpenStruct.new(
        name: 'testroom-10101010',
        light_id: 1,
        command: { 'on' => true },
        time: '2010-10-10T10:10:00-07:00'
      )

      schedule.items.should == [item]
    end
  end
end
