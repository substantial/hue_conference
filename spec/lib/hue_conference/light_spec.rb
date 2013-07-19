require 'spec_helper'

describe "HueConference::Light" do
  let(:light_hash) {
    { "1" => { "name" => "Bedroom" } }
  }
  let(:mock_client) { double.as_null_object }

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
    mock_client = double
    @light.client = mock_client
    @light.client.should == mock_client
  end

  describe "turn on/off" do
    let(:mock_client) { double }

    before do
      @light.client = mock_client
    end

    it "should turn on the light" do
      @light.instance_variable_set(:@on, false)
      @light.should_receive(:update_state).with(on: true)
      @light.turn_on
    end

    it "should turn off the light" do
      @light.instance_variable_set(:@on, true)
      @light.should_receive(:update_state).with(on: false)
      @light.turn_off
    end
  end

  describe "#sync!" do
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
          "colormode"=> "hs",
          "transitiontime"=> 200
        }
      }
    }
    let(:response) { double(data: light_state) }

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
      @light.instance_variable_get(:@on).should be_false
    end

    it "should sync the hue state" do
      @light.sync!
      @light.instance_variable_get(:@hue).should == 50000
    end

    it "should sync the brightness state" do
      @light.sync!
      @light.instance_variable_get(:@bri).should == 200
    end

    it "should sync the saturation state" do
      @light.sync!
      @light.instance_variable_get(:@sat).should == 200
    end

    it "should sync the color temperature state" do
      @light.sync!
      @light.instance_variable_get(:@ct).should == 500
    end

    it "should sync the alert state" do
      @light.sync!
      @light.instance_variable_get(:@alert).should == "none"
    end

    it "should sync the effect state" do
      @light.sync!
      @light.instance_variable_get(:@effect).should == "none"
    end

    it "should sync the transition time state" do
      @light.sync!
      @light.instance_variable_get(:@transitiontime).should == 200
    end
  end

  describe "#toggle" do
    it "should turn on if off" do
      @light.should_receive(:turn_on)
      @light.should_not_receive(:turn_off)
      @light.instance_variable_set(:@on, false)
      @light.toggle
    end

    it "should turn off if on" do
      @light.should_receive(:turn_off)
      @light.should_not_receive(:turn_on)
      @light.instance_variable_set(:@on, true)
      @light.toggle
    end
  end

  describe "update_state" do
    let(:result_array) {
      [
        {"success"=>{"/lights/2/state/on"=>true}},
        {"success"=>{"/lights/2/state/hue"=>500}},
        {"success"=>{"/lights/2/state/bri"=>98}}
      ]
    }
    let(:response) { double(data: result_array) }

    before do
      mock_client.stub(put: response)
    end

    it "should update properties in the result array" do
      @light.client = mock_client
      @light.send(:update_state)
      @light.instance_variable_get(:@on).should == true
      @light.instance_variable_get(:@hue).should == 500
      @light.instance_variable_get(:@bri).should == 98
    end
  end

  describe "validate_factor" do
    it "should only allow a float for 0.0 to 1.0" do
      expect { @light.send(:validate_factor, 1.1) }.to raise_error HueConference::FloatOutOfRange, "Number must be between 0.0 to 1.0"
    end
  end

  describe "#brightness" do
    before do
      @light.stub(:update_state)
    end

    it "should update the brightness" do
      @light.should_receive(:update_state).with(bri: 128)
      @light.brightness(0.5)
    end
  end

  describe "#saturation" do
    before do
      @light.stub(:update_state)
    end

    it "should update the saturation" do
      @light.should_receive(:update_state).with(sat: 191)
      @light.saturation(0.75)
    end
  end
end

