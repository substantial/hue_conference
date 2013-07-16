require 'ruhue'

class HueConference::LightManifest

  attr_reader :client, :lights

  def initialize(ruhue_client)
    @client = ruhue_client
    @lights = []
  end

  def build_manifest
    lights_hash = @client.get("/lights")
    lights_hash.each_pair do |light_id, light_properties|
      light = HueConference::Light.new(light_id, light_properties)
      light.client = @client
      @lights << light
    end
  end

end
