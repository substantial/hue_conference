module HueConference
  class MissingConfigOptions < Exception; end

  class GoogleTravelAgent
    require 'google/api_client'

    attr_reader :client

    def initialize(config)
      [:application_name, :key_location, :google_service_email].each do |key|
        unless config.has_key?(key)
          raise MissingConfigOptions, "config is missing #{key}"
        end
      end

      @application_name = config[:application_name]
      @key_location = config[:key_location]
      @google_service_email = config[:google_service_email]

      @client = Google::APIClient.new(application_name: @application_name)
    end

    def calendar_events(calendar_id)
      @client.authorization = service_account.authorize

      options = {'calendarId' => calendar_id}
      result = @client.execute(api_method: calendar_service.events.list, parameters: options)

      result.data
    end

    private

    def default_scope
      'https://www.googleapis.com/auth/prediction'
    end

    def calendar_scope
      'https://www.googleapis.com/auth/calendar.readonly'
    end

    def scopes
      s = []
      s << default_scope
      s << calendar_scope
      s
    end

    def api_key
      @api_key ||= Google::APIClient::PKCS12.load_key(@key_location, 'notasecret')
    end

    def service_account
      Google::APIClient::JWTAsserter.new(@google_service_email, scopes, api_key)
    end

    def calendar_service
      @client.discovered_api('calendar', 'v3')
    end
  end
end
