require 'spec_helper'

describe HueConference::Attribute do

  describe "#update_state" do
    let(:new_attributes) { { on: true, brightness: 1 } }
    let(:attributes) { HueConference::Attribute.multiple(new_attributes) }

    before do
    end

    it "should convert each state property" do
      #light.should_receive(:brightness).with(1.0)
      #light.should_receive(:color).with('red')
      #light.should_receive(:on).with(true)
      #HueConference::Attribute.should_receive(:on)

      attributes.should == {
        on: true,
        bri: 255
      }
    end

    it "should set the state from the built up the request" do
      #converted_hash = { hue: 'red', on: true, bri: 'bar'  }
      #light.should_receive(:write_state).with(converted_hash)

      #light.update_state(on: true, color: 'red')
    end

    it "should choose explicit brightness over color" do
      #converted_hash = { hue: 'red', on: true, bri: 'foo'  }
      #light.should_receive(:write_state).with(converted_hash)

      #light.update_state(brightness: 1.0, on: true, color: 'red')
    end
  end
end
