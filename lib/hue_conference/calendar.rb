module HueConference
  class Calendar
    require 'google/api_client'

    attr_reader :id

    def initialize(calendar_id)
      @id = calendar_id
    end
  end
end
