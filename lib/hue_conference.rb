require "hue_conference/version"
require "hue_conference/room"
require "hue_conference/light"
require "hue_conference/light_manifest"
require "hue_conference/calendar"
require "hue_conference/event"
require "hue_conference/room_builder"
require "google-api-middle_man"

module HueConference

  class Application

    attr_reader :google_agent, :client, :light_manifest

    def initialize(config)
      @google_agent = GoogleAPIMiddleMan::Agent.new(config['google_config'])
      setup_ruhue_client(config["hue_account_name"])

      @light_manifest = HueConference::LightManifest.new(@client)

      @rooms_config = config['rooms']
    end

    def rooms
      build_rooms if @rooms.nil?
      @rooms
    end

    private

    def build_rooms
      @rooms = HueConference::RoomBuilder.new(@rooms_config, @light_manifest, @google_agent).build
    end

    def setup_ruhue_client(hue_account_name)
      hue = Ruhue.discover
      @client = Ruhue::Client.new(hue, hue_account_name)

      if @client.registered?
        puts "It appears your already registered with the Hub. Play away!"
      elsif @client.register("ruhue")
        puts "A new application has been registered with the Hub as #{@client.username}. Play away!"
      end
    end
  end
end

