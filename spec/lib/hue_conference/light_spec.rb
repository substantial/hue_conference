require 'spec_helper'

describe "HueConference::Light" do
  let(:light_hash) {
    { "1" => { "name" => "Bedroom" } }
  }
  let(:mock_client) { double.as_null_object }
  let(:light) { HueConference::Light.new("1", light_hash["1"]) }

  it "should have a name" do
    light.name.should == "Bedroom"
  end

  it "should have an id" do
    light.id.should == "1"
  end

  it "should take a client" do
    mock_client = double
    light.client = mock_client
    light.client.should == mock_client
  end

  describe "turn on/off" do
    let(:mock_client) { double }

    before do
      light.client = mock_client
    end

    it "should turn on the light" do
      light.should_receive(:write_state).with(on: true)
      light.on!
    end

    it "should turn off the light" do
      light.should_receive(:write_state).with(on: false)
      light.off!
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
      light.client = mock_client
      mock_client.stub(:get).and_return(response)
    end

    it "should fetch the state" do
      mock_client.should_receive("get").with("/lights/1")
      light.sync!
    end

    it "should set the 'on' state" do
      light.sync!
      light.instance_variable_get(:@on).should be_false
    end

    it "should sync the hue state" do
      light.sync!
      light.instance_variable_get(:@hue).should == 50000
    end

    it "should sync the brightness state" do
      light.sync!
      light.instance_variable_get(:@bri).should == 200
    end

    it "should sync the saturation state" do
      light.sync!
      light.instance_variable_get(:@sat).should == 200
    end

    it "should sync the color temperature state" do
      light.sync!
      light.instance_variable_get(:@ct).should == 500
    end

    it "should sync the alert state" do
      light.sync!
      light.instance_variable_get(:@alert).should == "none"
    end

    it "should sync the effect state" do
      light.sync!
      light.instance_variable_get(:@effect).should == "none"
    end

    it "should sync the transition time state" do
      light.sync!
      light.instance_variable_get(:@transitiontime).should == 200
    end
  end

  describe "#reset!" do

    let(:reset_state) {
      {
        on: true,
        hue: 0,
        sat: 0,
        bri: 128,
      }
    }

    before do
      light.stub(:write_state)
    end

    it "should reset the lights to white" do
      light.should_receive(:write_state).with(reset_state)
      light.reset!
    end
  end

  describe "#debug" do

    before do
      light.client = mock_client
      mock_client.stub(:get).and_return('foo')
    end

    it "should return the attributes & state for light" do
      mock_client.should_receive("get").with("/lights/1")
      light.debug.should == 'foo'
    end
  end

  describe "#toggle" do
    it "should turn on if off" do
      light.instance_variable_set(:@on, false)
      light.should_receive(:on!)
      light.should_not_receive(:off!)
      light.toggle
    end

    it "should turn off if on" do
      light.instance_variable_set(:@on, true)
      light.should_receive(:off!)
      light.should_not_receive(:on!)
      light.toggle
    end
  end

  describe "#brightness!" do
    before do
      light.stub(:write_state)
    end

    it "should update the brightness" do
      light.should_receive(:write_state).with(bri: 128)
      light.brightness!(0.5)
    end
  end

  describe "#saturation!" do
    before do
      light.stub(:write_state)
    end

    it "should update the saturation" do
      light.should_receive(:write_state).with(sat: 191)
      light.saturation!(0.75)
    end
  end

  describe "#color!" do
    before do
      light.stub(:write_state)
    end

    it "should convert the Color::RGB to HSL" do
      hsl_color = double(l: 0.5, s: 0.5, h: 0.5)

      color = double(to_hsl: hsl_color)
      color.should_receive(:to_hsl)

      calculated_colors = { bri: 128, sat: 128, hue: 32768, transitiontime: 1 }

      light.should_receive(:write_state).with(calculated_colors)
      light.color!(color)
    end
  end

  describe "#blink!" do
    before do
      light.stub(:write_state)
    end

    it "should blink the light" do
      light.should_receive(:write_state).with(alert: 'lselect')
      light.blink!(true)
    end

    it "should stop blinking the light" do
      light.should_receive(:write_state).with(alert: 'none')
      light.blink!(false)
    end
  end

  describe "#colorloop!" do
    before do
      light.stub(:write_state)
    end

    it "should color loop the light" do
      light.should_receive(:write_state).with(effect: 'colorloop')
      light.colorloop!(true)
    end

    it "should stop color looping the light" do
      light.should_receive(:write_state).with(effect: 'none')
      light.colorloop!(false)
    end
  end

  describe "#transition" do
    before do
      light.stub(:write_state)
    end

    it "should set the transition time" do
      light.should_receive(:write_state).with(transitiontime: 10)
      light.transition!(1)
    end
  end
end

