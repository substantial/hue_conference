module HueConference
  class RequireLightManifest < Exception; end
  class RequireGoogleAPIMiddleManAgent < Exception; end

  class RoomBuilder

    def initialize(rooms_config, light_manifest, google_agent)
      raise RequireLightManifest unless light_manifest.is_a? LightManifest
      raise RequireGoogleAPIMiddleManAgent unless google_agent.is_a? GoogleAPIMiddleMan::Agent

      @rooms_config = rooms_config
      @light_manifest = light_manifest
      @google_agent = google_agent
    end

    def build
      rooms = []
      @rooms_config.each do |room_config|
        room = HueConference::Room.new(room_config)

        calendar = HueConference::Calendar.new(room_config["calendar_id"], @google_agent)

        room.calendar = calendar

        build_lights(room, room_config['lights'])
        rooms << room
      end
      rooms
    end

    private

    def build_lights(room, lights)
      lights.each do |light|
        l = @light_manifest.find_light(light["name"])
        next if l.nil?
        l.location = light["location"]
        room.lights << l
      end
    end
  end
end

