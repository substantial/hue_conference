require "spec_helper"

describe HueConference::Scheduler do
  let(:hue_client) { double.as_null_object }
  let(:rooms) { [double.as_null_object] }

  describe "#initialize" do
    it "should require a RueHue client" do
      expect { HueConference::Scheduler.new }.to raise_error ArgumentError
    end

    it "should require a rooms array" do
      expect { HueConference::Scheduler.new(hue_client) }.to raise_error ArgumentError
    end

    it "should have a RueHue client" do
      scheduler = HueConference::Scheduler.new(hue_client, rooms)
      scheduler.client.should == hue_client
    end

    it "should have rooms" do
      scheduler = HueConference::Scheduler.new(hue_client, rooms)
      scheduler.rooms.should == rooms
    end
  end

  describe "#schedule_rooms" do
    let(:scheduler) { HueConference::Scheduler.new(hue_client, rooms) }

    it "should schedule all rooms" do
      scheduler.schedule_rooms
    end
  end

end
