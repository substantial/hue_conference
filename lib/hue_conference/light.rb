module HueConference

  class FloatOutOfRange < Exception; end

  class Light
    attr_reader :name, :id
    attr_accessor :client, :location

    STATE_PROPERTIES = %w[on hue bri sat ct alert effect transitiontime]
    MAX_BRIGHTNESS = 255
    MAX_SATURATION = 255
    MAX_HUE = 65536

    def initialize(id, properties = {})
      @id = id
      @name = properties['name']
    end

    def turn_on
      update_state(on: true) unless @on
    end

    def turn_off
      update_state(on: false) if @on
    end

    def sync!
      light_state = @client.get("/lights/#{id}").data['state']
      STATE_PROPERTIES.each do |property|
        instance_variable_set("@#{property}".to_sym, light_state[property])
      end
    end

    def color(new_color)
      hsl = new_color.to_hsl
      update_state(bri: (hsl.l * MAX_BRIGHTNESS).round,
                   sat: (hsl.s * MAX_SATURATION).round,
                   hue: (hsl.h * MAX_HUE).round
                  )
    end

    def toggle
      @on ? turn_off : turn_on
    end

    def hue(new_hue)
      invalid = new_hue > MAX_HUE || new_hue < 0
      raise OutOfRange, "Value must be integer between 0 - #{MAX_HUE}" if invalid
      update_state(hue: new_hue)
    end

    def brightness(factor)
      validate_factor(factor)
      update_state(bri: (MAX_BRIGHTNESS * factor).round )
    end

    def saturation(factor)
      validate_factor(factor)
      update_state(sat: (MAX_SATURATION * factor).round )
    end

    private

    def validate_factor(factor)
      invalid = (factor < 0.0 || factor > 1.0)
      raise FloatOutOfRange, "Number must be between 0.0 to 1.0" if invalid
    end

    def update_state(new_state={})
      result = @client.put("/lights/#{id}/state", new_state)

      result.data.each do |state|
        if state.has_key?('success')
          state['success'].each do |state_property|
            property_name = state_property.first.match('[a-zA-z]*$').to_s
            property_sym = "@#{property_name}".to_sym
            property_value = state_property.last

            instance_variable_set(property_sym, property_value)
          end
        end
      end
    end
  end

end
