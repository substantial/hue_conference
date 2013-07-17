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

  describe "turn on/off" do
    let(:mock_client) { mock }

    before do
      @light.client = mock_client
    end

    it "should turn on the light" do
      mock_client.should_receive("put").with("/lights/1/state", on: true)
      @light.stub(:on?) { false }
      @light.turn_on
    end

    it "should turn off the light" do
      @light.stub(:on?) { true }
      mock_client.should_receive("put").with("/lights/1/state", on: false)
      @light.turn_off
    end
  end

  describe "#sync_state" do
    let(:mock_client) { mock }

    let(:light_state) {
      {
        "state"=> {
          "hue"=> 50000,
          "on"=> false,
          "effect"=> "none",
          "alert"=> "none",
          "bri"=> 200,
          "sat"=> 200,
          "ct"=> 500,
          "xy"=> [0.5, 0.5],
          "reachable"=> true,
          "colormode"=> "hs"
        }
      }
    }
    let(:response) { mock_response = mock
                     mock_response.stub(:data).and_return(light_state)
                     mock_response
    }


    before do
      @light.client = mock_client
      mock_client.stub(:get).and_return(response)
    end

    it "should fetch the state" do
      mock_client.should_receive("get").with("/lights/1")
      @light.sync!
    end

    it "should set the 'on' state" do
      @light.sync!
      @light.on?.should be_false
    end
  end

  describe "#on?" do
    it "should know if it's on" do
      @light.on?.should == true
    end
  end

  describe "#toggle" do
    it "should turn on if off" do
      @light.should_receive(:turn_on)
      @light.should_not_receive(:turn_off)
      @light.stub(:on?) { false }
      @light.toggle
    end

    it "should turn off if on" do
      @light.should_receive(:turn_off)
      @light.should_not_receive(:turn_on)
      @light.stub(:on?) { true }
      @light.toggle
    end
  end
end

