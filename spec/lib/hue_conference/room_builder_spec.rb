require "spec_helper"

describe "HueConference::RoomBuilder" do
  let(:light_hash) { {"name" => "light_name", "location" => "some location"} }
  let(:rooms_config) {
    [
      "name" => "room_name",
      "calendar_id" => "some_calendar_id",
      "lights" => [ light_hash ]
    ]
  }
  let(:light_manifest) { double(is_a?: true) }
  let(:google_agent) { double(is_a?: true) }

  describe "#initialize" do
    it "should require a config hash" do
      expect { HueConference::RoomBuilder.new }.to raise_error ArgumentError
    end

    it "should require a light manifest" do
      expect { HueConference::RoomBuilder.new(rooms_config) }.to raise_error ArgumentError
    end

    it "should require a travel agent" do
      expect { HueConference::RoomBuilder.new(rooms_config, light_manifest) }.to raise_error ArgumentError
    end

    it "should require the light manifest, to be a light manifest" do
      expect { HueConference::RoomBuilder.new(rooms_config, double, google_agent) }.to raise_error HueConference::RequireLightManifest
    end

    it "should require the google agent, to be a google agent" do
      expect { HueConference::RoomBuilder.new(rooms_config, light_manifest, double) }.to raise_error HueConference::RequireGoogleAPIMiddleManAgent
    end
  end

  describe "#build" do

    let(:light) { double.as_null_object }
    let(:light_manifest) { double(is_a?: true, find_light: light) }
    let(:google_agent) { double(is_a?: true, calendar_events: 'some calendar events') }
    let(:builder) { HueConference::RoomBuilder.new(rooms_config, light_manifest, google_agent) }
    let(:room) { double.as_null_object }
    let(:calendar) { double.as_null_object }

    before do
      HueConference::Calendar.stub(new: calendar)
      HueConference::Room.stub(new: room)
    end

    it "should create a calendar for each room" do
      HueConference::Calendar.should_receive(:new).with(rooms_config.first["calendar_id"])
      builder.build
    end

    it "should build events for a calendar" do
      calendar.should_receive(:build_events).with('some calendar events')
      builder.build
    end

    it "should create a room" do
      HueConference::Room.should_receive(:new).with(rooms_config.first)
      builder.build
    end

    it "should give the room its calendar" do
      room.should_receive(:calendar=).with(calendar)
      builder.build
    end

    it "should look for the light in the light manifest" do
      light_manifest.should_receive(:find_light).with(light_hash['name'])
      builder.build
    end

    it "should set the lights location" do
      light.should_receive(:location=).with(light_hash['location'])
      builder.build
    end

    it "should add the light to the room" do
      room.lights.should_receive(:<<).with(light)
      builder.build
    end

    it "should return an array of rooms" do
      builder.build.should == [room]
    end
  end
end
