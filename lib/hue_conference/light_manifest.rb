require 'ruhue'
require 'hue_conference/light'

class HueConference::LightManifest

  attr_reader :client

  def initialize(ruhue_client)
    @client = ruhue_client
    @lights = []
  end

  def build_manifest
    @lights.clear
    lights_hash = @client.get("/lights").data
    lights_hash.each_pair do |light_id, light_properties|
      light = HueConference::Light.new(light_id, light_properties)
      light.client = @client
      light.reset!
      light.off!
      light.sync!
      @lights << light
    end
  end

  def lights
    build_manifest if @lights.empty?
    @lights
  end

  def lights!
    build_manifest
    @lights
  end

  def find_light(light_name)
    lights.select do |light|
      light.name == light_name
    end.first
  end
end

