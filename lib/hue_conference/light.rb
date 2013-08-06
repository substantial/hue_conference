require 'hue_conference/light_options'

module HueConference

  class FloatOutOfRange < Exception; end

  class Light
    include LightOptions
    attr_reader :name, :id
    attr_accessor :client, :location

    STATE_PROPERTIES = %w[on hue bri sat ct alert effect transitiontime]

    def initialize(id, properties = {})
      @id = id
      @name = properties['name']
    end

    def on!
      update_state(on(true))
    end

    def off!
      update_state(on(false))
    end

    def sync!
      light_state = @client.get("/lights/#{id}").data['state']

      STATE_PROPERTIES.each do |property|
        instance_variable_set("@#{property}".to_sym, light_state[property])
      end
    end

    def reset!
      reset_state = {
        on: true,
        hue: 0,
        saturation: 0,
        brightness: 0.5,
      }
      update_state(reset_state)
    end

    def debug
      @client.get("/lights/#{@id}")
    end

    def toggle
      @on ? off! : on!
    end

    def color!(new_color)
      write_state(color(new_color))
    end

    def hue!(new_hue)
      write_state(hue(new_hue))
    end

    def brightness!(factor)
      write_state(brightness(factor))
    end

    def saturation!(factor)
      write_state(saturation(factor))
    end

    def update_state(new_state = {})
      options = {}

      if new_state.has_key?(:color)
        color_state = new_state.delete(:color)
        options.merge!(self.send(:color, color_state))
      end

      new_state.keys.each do |key|
        options.merge!(self.send(key, new_state[key]))
      end

      write_state(options)
    end

    private

    def write_state(new_state={})
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

