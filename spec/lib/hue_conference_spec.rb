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
  let(:rooms_config) { config_hash["rooms"] }
  let(:rooms) { double }
  let(:room_builder) { double(build: rooms) }

  before do
    GoogleAPIMiddleMan::Agent.stub(new: google_agent)
    Ruhue::Client.stub(new: hue_client)
    Ruhue.stub(discover: hue_bridge)
    HueConference::LightManifest.stub(new: light_manifest)
    HueConference::RoomBuilder.stub(new: room_builder)
    $stdout.stub(:puts)
  end

  describe "#initialize" do
    it "should require a config hash" do
      expect { HueConference::Application.new }.to raise_error ArgumentError
    end

    it "should create a google_agent" do
      GoogleAPIMiddleMan::Agent.should_receive(:new).with(config_hash["google_config"])
      app = HueConference::Application.new(config_hash)
    end

    it "should discover the Hue bridge" do
      Ruhue.should_receive(:discover)
      app = HueConference::Application.new(config_hash)
    end

    it "should discover the Ruhue client" do
      Ruhue::Client.should_receive(:new).with(hue_bridge, config_hash["hue_account_name"])
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

    it "should build the rooms" do
      HueConference::RoomBuilder.should_receive(:new).with(rooms_config, light_manifest, google_agent)
      room_builder.should_receive(:build)
      app = HueConference::Application.new(config_hash)
    end

    it "should have rooms" do
      app = HueConference::Application.new(config_hash)
      app.rooms.should == rooms
    end
  end

  describe "#create_schedule" do
    let(:app) { HueConference::Application.new(config_hash) }
    let(:response) { 'some response' }
    let(:scheduler) { double(schedule_rooms: response) }
    let(:schedule) { double }

    before do
      HueConference::Scheduler.stub(new: scheduler)
    end

    it "should schedule each room" do
      HueConference::Scheduler.should_receive(:new).with(hue_client, rooms)
      app.create_schedule.should == response
    end
  end

  describe "#schedule" do
    let(:app) { HueConference::Application.new(config_hash) }
    let(:schedule) { double }
    let(:scheduler) { double(all_schedules: schedule) }

    before do
      HueConference::Scheduler.stub(new: scheduler)
    end

    it "should return the hue schedule" do
      scheduler.should_receive(:all_schedules)
      app.schedule.should == schedule
    end
  end

  describe "#scheduler" do
    let(:app) { HueConference::Application.new(config_hash) }
    let(:client) { double('hue client') }
    let(:rooms) { double('rooms') }
    let(:scheduler) { double('scheduler') }

    before do
      HueConference::Scheduler.stub(:new) { scheduler }
      app.instance_variable_set(:@client, client)
      app.instance_variable_set(:@rooms, rooms)
    end

    it "should create a new scheduler" do
      HueConference::Scheduler.should_receive(:new).with(client, rooms)
      app.scheduler.should == scheduler
    end

    it "should not create a new schedule if one already created" do
      app.instance_variable_set(:@scheduler, scheduler)
      HueConference::Scheduler.should_not_receive(:new)
      app.scheduler
    end
  end
end

