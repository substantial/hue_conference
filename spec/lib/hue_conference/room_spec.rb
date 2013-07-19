require 'spec_helper'

describe "HueConference::Room" do

  let(:room_config_hash) { { name: "Test Room" } }
  let(:room) { HueConference::Room.new(room_config_hash) }

  it "should have name" do
    room.name.should == 'Test Room'
  end

  it "should have a light" do
    light = double
    room.lights << light
    room.lights.should include light
  end

  it "should have a calendar" do
    calendar = double
    room.calendar = calendar
    room.calendar.should == calendar
  end

  it "should be able to turn off lights" do
    light = double
    light.stub(:off)
    room.lights << light
    light.should_receive(:off)
    room.turn_off_lights
  end

  it "should be able to turn on lights" do
    light = double
    light.stub(:on)
    room.lights << light
    light.should_receive(:on)
    room.turn_on_lights
  end

  describe "#find_light" do
    it "should return the matching light by location" do
      indoor_light = double(location: "indoor")
      outdoor_light = double(location: "outdoor")

      room.lights << outdoor_light << indoor_light

      room.find_light("indoor").should == indoor_light
    end
  end

  describe "#starting_event" do
    it "should call the event_starting_callback" do
      result = nil
      room.on_event_start do |r|
        result = true
        r.should eq(room)
      end

      room.event_starting

      result.should be_true
    end

    it "shouldn't blow up if callback isn't set" do
      expect { room.event_starting }.not_to raise_error
    end
  end

  describe "#ending_event" do
    it "should call the event_ending_callback" do
      result = nil
      room.on_event_end do |r|
        result = true
        r.should eq(room)
      end

      room.event_ending

      result.should be_true
    end

    it "shouldn't blow up if callback isn't set" do
      expect { room.event_ending }.not_to raise_error
    end
  end

  describe "#next_start_time" do
    it "should return a time" do
      room.stub_chain(:calendar, :next_event, :start_time) { DateTime.new }
      room.next_start_time.should be_a DateTime
    end
  end

  describe "#next_end_time" do
    it "should return a time" do
      room.stub_chain(:calendar, :next_event, :end_time) { DateTime.new }
      room.next_end_time.should be_a DateTime
    end
  end
end

