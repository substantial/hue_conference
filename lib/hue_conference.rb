require "ostruct"
require "google-api-middle_man"
require "color"

require "hue_conference/version"
require "hue_conference/room"
require "hue_conference/light"
require "hue_conference/light_manifest"
require "hue_conference/calendar"
require "hue_conference/event"
require "hue_conference/room_builder"
require "hue_conference/scheduler"
require "hue_conference/schedule"

module HueConference

  class Application

    attr_reader :client, :rooms

    def initialize(config)
      google_agent = GoogleAPIMiddleMan::Agent.new(config['google_config'])

      setup_ruhue_client(config["hue_account_name"])

      light_manifest = HueConference::LightManifest.new(@client)

      rooms_config = config['rooms']

      @rooms = HueConference::RoomBuilder.new(config['rooms'], light_manifest, google_agent).build
    end

    def create_schedule
      scheduler.schedule_rooms
    end

    def schedule
      scheduler.all_schedules
    end

    def scheduler
      @scheduler ||= HueConference::Scheduler.new(@client, @rooms)
    end

    private

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

