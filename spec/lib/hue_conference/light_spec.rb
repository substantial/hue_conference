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
      @light.should_receive(:update_state).with(on: true)
      @light.on!
    end

    it "should turn off the light" do
      @light.should_receive(:update_state).with(on: false)
      @light.off!
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

  describe "#reset!" do

    let(:reset_state) {
      {
        on: true,
        hue: 0,
        saturation: 0,
        brightness: 0.5,
      }
    }

    it "should reset the lights to white" do
      @light.should_receive(:update_state).with(reset_state)
      @light.reset!
    end
  end

  describe "#debug" do

    before do
      @light.client = mock_client
      mock_client.stub(:get).and_return('foo')
    end

    it "should return the attributes & state for light" do
      mock_client.should_receive("get").with("/lights/1")
      @light.debug.should == 'foo'
    end
  end

  describe "#toggle" do
    it "should turn on if off" do
      @light.instance_variable_set(:@on, false)
      @light.should_receive(:on!)
      @light.should_not_receive(:off!)
      @light.toggle
    end

    it "should turn off if on" do
      @light.instance_variable_set(:@on, true)
      @light.should_receive(:off!)
      @light.should_not_receive(:on!)
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

  describe "#brightness!" do
    before do
      @light.stub(:write_state)
    end

    it "should update the brightness" do
      @light.should_receive(:write_state).with(bri: 128)
      @light.brightness!(0.5)
    end
  end

  describe "#saturation!" do
    before do
      @light.stub(:write_state)
    end

    it "should update the saturation" do
      @light.should_receive(:write_state).with(sat: 191)
      @light.saturation!(0.75)
    end
  end

  describe "#color!" do
    before do
      @light.stub(:write_state)
    end

    it "should convert the Color::RGB to HSL" do
      hsl_color = double(l: 0.5, s: 0.5, h: 0.5)

      color = double(to_hsl: hsl_color)
      color.should_receive(:to_hsl)

      calculated_colors = { bri: 128, sat: 128, hue: 32768, transitiontime: 1 }

      @light.should_receive(:write_state).with(calculated_colors)
      @light.color!(color)
    end
  end

  describe "#update_state" do
    before do
      @light.stub(:write_state)
      @light.stub(brightness: {bri: 'foo'})
      @light.stub(color: {hue: 'red', bri: 'bar'})
      @light.stub(on: {on: true})
    end

    it "should convert each state property" do
      @light.should_receive(:brightness).with(1.0)
      @light.should_receive(:color).with('red')
      @light.should_receive(:on).with(true)

      @light.update_state(brightness: 1.0, on: true, color: 'red')
    end

    it "should set the state from the built up the request" do
      converted_hash = { hue: 'red', on: true, bri: 'bar'  }
      @light.should_receive(:write_state).with(converted_hash)

      @light.update_state(on: true, color: 'red')
    end

    it "should choose explicit brightness over color" do
      converted_hash = { hue: 'red', on: true, bri: 'foo'  }
      @light.should_receive(:write_state).with(converted_hash)

      @light.update_state(brightness: 1.0, on: true, color: 'red')
    end
  end
end

