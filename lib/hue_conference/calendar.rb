module HueConference
  class RequireGoogleServiceError < Exception; end

  class Calendar
    require 'google/api_client'

    attr_reader :id

    def initialize(google_calendar_service, calendar_id)
      unless google_calendar_service.is_a? Google::APIClient::JWTAsserter
        raise RequireGoogleServiceError
      end

      @id = calendar_id
    end

  end
end
