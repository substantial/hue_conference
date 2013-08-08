require 'spec_helper'

describe "HueConference::Room" do

  let(:room_config_hash) { { 'name' => "Test Room - Over 20 Characters Long" } }
  let(:room) { HueConference::Room.new(room_config_hash) }

  describe "#initialize" do
    it "should require a room config hash" do
      expect { HueConference::Room.new }.to raise_error ArgumentError
    end

    it "should have formatted name" do
      room.name.should == 'testroomover20charac'
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
  end

  describe "#has_upcoming_event?" do

    before do
      room.stub(:calendar_events) { [double] }
    end

    it "should return true if there is an upcoming event" do
      room.has_upcoming_event?.should == true
    end
  end

  describe "calendar_events" do
    it "should return the event callbacks to be scheduled" do
      callbacks = [double('event callback')]

      room.stub(:calendar) { double(event_callbacks: callbacks) }
      room.calendar_events.should == callbacks
    end
  end

  describe "#turn_on_lights" do
    it "should be able to turn on lights" do
      light = double
      light.stub(:on!)
      room.lights << light
      light.should_receive(:on!)
      room.turn_on_lights
    end
  end

  describe "#turn_off_lights" do
    it "should be able to turn off lights" do
      light = double
      light.stub(:off!)
      room.lights << light
      light.should_receive(:off!)
      room.turn_off_lights
    end
  end

  describe "#find_light" do
    it "should return the matching light by location" do
      indoor_light = double(location: "indoor")
      outdoor_light = double(location: "outdoor")

      room.lights << outdoor_light << indoor_light

      room.find_light("indoor").should == indoor_light
    end
  end
end

