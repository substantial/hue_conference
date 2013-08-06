require 'spec_helper'

describe "HueConference::Room" do

  let(:room_config_hash) { { 'name' => "Test Room" } }
  let(:room) { HueConference::Room.new(room_config_hash) }

  describe "#initialize" do
    it "should have formatted name" do
      room.name.should == 'test_room'
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
      HueConference::Calendar.stub(:new) { double }
      room.stub(:event) { double }
    end

    it "should return true if there is an upcoming event" do
      room.has_upcoming_event?.should == true
    end
  end

  describe "event" do
    it "should return the calendar event to be scheduled" do
      event = double('calendar event')
      room.stub_chain(:calendar, :current_event) { event }
      room.calendar.should_receive(:current_event)
      room.event.should == event
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

