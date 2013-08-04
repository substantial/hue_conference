require 'spec_helper'

describe HueConference::LightManifest do

  describe "#initialize" do
    it "should take a Ruhue Client" do
      hue = double
      ruhue_client = Ruhue::Client.new(hue, "foousername")
      manifest = HueConference::LightManifest.new(ruhue_client)
      manifest.client.should be_a Ruhue::Client
    end

    it "should have a collection of lights" do
      hue = double
      ruhue_client = Ruhue::Client.new(hue, "foousername")
      manifest = HueConference::LightManifest.new(ruhue_client)
      manifest.stub(:build_manifest)
      manifest.lights.should be_a Array
    end
  end

  describe "#build_manifest" do
    let(:light) { double.as_null_object }
    let(:hue) { double }
    let(:ruhue_client) { Ruhue::Client.new(hue, "foousername") }
    let(:manifest) { HueConference::LightManifest.new(ruhue_client) }
    let(:response_data) {
      {
        "1" => { "name" => "Bedroom" },
        "2" => { "name" => "Kitchen" }
      }
    }

    before do
      @response = double
      @response.stub(:data).and_return(response_data)
      ruhue_client.stub(:get) { @response }
      HueConference::Light.stub(:new) { light }
    end

    it "should return a list of lights" do
      ruhue_client.should_receive(:get).with("/lights")
      manifest.build_manifest
    end

    it "should clear the existings lights" do
      ruhue_client.stub_chain(:get, :data) { {} }

      manifest.instance_variable_set(:@lights, ['foo'])
      manifest.build_manifest
      manifest.instance_variable_get(:@lights).should be_empty
    end

    it "should instantiate lights" do
      HueConference::Light.should_receive(:new).with("1", response_data["1"])
      HueConference::Light.should_receive(:new).with("2", response_data["2"])
      manifest.build_manifest
    end

    it "should sync the lights" do
      light.should_receive(:sync!)
      manifest.build_manifest
    end
  end

  describe "#lights" do
    let(:manifest) { HueConference::LightManifest.new(double) }

    before do
      manifest.stub(:build_manifest)
    end

    it "should build the manifest if lights are empty" do
      manifest.should_receive(:build_manifest)
      manifest.lights
    end

    it "shouldn't build the manifest if lights aren't empty" do
      manifest.instance_variable_set(:@lights, ['foo'])
      manifest.should_not_receive(:build_manifest)
      manifest.lights
    end
  end

  describe "#lights!" do
    let(:manifest) { HueConference::LightManifest.new(double) }

    before do
      manifest.stub(:build_manifest)
    end

    it "should force build manifest" do
      manifest.instance_variable_set(:@lights, ['foo'])
      manifest.should_receive(:build_manifest)
      manifest.lights!
    end
  end

  describe "#find_light" do
    let(:manifest) { HueConference::LightManifest.new(double) }
    let(:foo_light) { double(name: "foo_light") }

    before do
      manifest.stub(:lights) { [foo_light] }
    end

    it "should return the light matching the given name" do
      manifest.find_light("foo_light").should == foo_light
    end
  end
end
