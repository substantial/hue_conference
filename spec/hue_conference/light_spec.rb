require 'spec_helper'

describe "HueConference::Light" do
  let(:light_hash) {
    { "1" => { "name" => "Bedroom" } }
  }

  before do
    @light = HueConference::Light.new("1", light_hash["1"])
  end

  it "should have a name" do
    @light.name.should == "Bedroom"
  end

  it "should have an id" do
    @light.id.should == "1"
  end

  it "should take a client" do
    mock_client = mock
    @light.client = mock_client
    @light.client.should == mock_client
  end

  describe "on/off" do
    let(:mock_client) { mock }

    before do
      @light.client = mock_client
    end

    it "should turn on the light" do
      mock_client.should_receive("put").with("/lights/1/state", on: true)
      @light.turn_on
    end

    it "should turn off the light" do
      mock_client.should_receive("put").with("/lights/1/state", on: false)
      @light.turn_off
    end
  end
end
