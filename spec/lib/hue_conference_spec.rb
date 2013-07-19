require "spec_helper"

describe "HueConference::Application" do
  let(:config_hash) {
    {
      "google_config" => "some google config",
      "hue_account_name" => "hue_account_name",
      "rooms" => [
        {"name" => "test room1" },
        {"name" => "test room2" },
      ]
    }
  }
  let(:google_agent) { double.as_null_object }
  let(:hue_bridge) { double.as_null_object }
  let(:hue_client) { double.as_null_object }
  let(:light_manifest) { double.as_null_object }

  before do
    GoogleAPIMiddleMan::Agent.stub(new: google_agent)
    Ruhue::Client.stub(new: hue_client)
    Ruhue.stub(discover: hue_bridge)
    HueConference::LightManifest.stub(new: light_manifest)
    $stdout.stub(:puts)
  end

  describe "#initialize" do
    it "should require a config hash" do
      expect { HueConference::Application.new }.to raise_error ArgumentError
    end

    it "should create a google_agent" do
      GoogleAPIMiddleMan::Agent.should_receive(:new).with("some google config")
      app = HueConference::Application.new(config_hash)
    end

    it "should have a google_agent" do
      app = HueConference::Application.new(config_hash)
      app.google_agent.should == google_agent
    end

    it "should discover the Hue bridge" do
      Ruhue.should_receive(:discover)
      app = HueConference::Application.new(config_hash)
    end

    it "should discover the Ruhue client" do
      Ruhue::Client.should_receive(:new).with(hue_bridge, "hue_account_name")
      app = HueConference::Application.new(config_hash)
    end

    it "should have a Ruhue client" do
      app = HueConference::Application.new(config_hash)
      app.client.should == hue_client
    end

    it "should create a light manifest" do
      HueConference::LightManifest.should_receive(:new).with(hue_client)
      app = HueConference::Application.new(config_hash)
    end

    it "should have a light manifest" do
      app = HueConference::Application.new(config_hash)
      app.light_manifest.should == light_manifest
    end
  end

  describe "#build_rooms" do
    let(:app) { HueConference::Application.new(config_hash) }
    let(:rooms_config) { config_hash["rooms"] }
    let(:rooms) { double }
    let(:room_builder) { double(build: rooms) }

    before do
      HueConference::RoomBuilder.stub(new: room_builder)
    end

    it "should build the rooms" do
      HueConference::RoomBuilder.should_receive(:new).with(rooms_config)
      room_builder.should_receive(:build)
      app.send(:build_rooms)
    end

    it "should keep the rooms" do
      app.send(:build_rooms).should == rooms
    end
  end

  describe "#rooms" do
    let(:app) { HueConference::Application.new(config_hash) }

    it "should build the room if hasn't already" do
      app.should_receive(:build_rooms)
      app.rooms
    end

    it "shouldn't build the room if already done" do
      app.instance_variable_set(:@rooms, double)
      app.should_not_receive(:build_rooms)
      app.rooms
    end
  end
end

