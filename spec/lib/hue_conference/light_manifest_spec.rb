require 'spec_helper'

describe HueConference::LightManifest do
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
    manifest.lights.should be_a Array
  end

  describe "#build_manifest" do
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
      HueConference::Light.stub(:new) {
        light_stub = double
        light_stub.stub(:client=)
        light_stub
      }
    end

    it "should return a list of lights" do
      ruhue_client.should_receive(:get).with("/lights")
      manifest.build_manifest
    end

    it "should instantiate lights" do
      HueConference::Light.should_receive(:new).with("1", response_data["1"])
      HueConference::Light.should_receive(:new).with("2", response_data["2"])
      manifest.build_manifest
    end
  end
end
