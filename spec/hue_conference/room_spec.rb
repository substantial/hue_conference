require 'spec_helper'

describe "HueConference::Room" do

  let(:room) { HueConference::Room.new('bar') }

  it "should have name" do
    room.name.should == 'bar'
  end

  it "should have a light" do
    light = mock
    room.lights << light
    room.lights.should include light
  end

  it "should be able to turn off lights" do
    light = mock
    light.stub(:off)
    room.lights << light
    light.should_receive(:off)
    room.turn_off_lights
  end

  it "should be able to turn on lights" do
    light = mock
    light.stub(:on)
    room.lights << light
    light.should_receive(:on)
    room.turn_on_lights
  end
end
