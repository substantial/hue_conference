module HueConference

  class Light
    attr_reader :name, :id
    attr_accessor :client, :location

    STATE_PROPERTIES = %w[on hue bri sat ct alert effect transitiontime]

    def initialize(id, properties = {})
      @id = id
      @name = properties['name']
    end

    def on!
      write_state(HueConference::Attribute.on(true))
    end

    def off!
      write_state(HueConference::Attribute.on(false))
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
      write_state(HueConference::Attribute.multiple(reset_state))
    end

    def debug
      @client.get("/lights/#{@id}")
    end

    def toggle
      @on ? off! : on!
    end

    def color!(new_color)
      write_state(HueConference::Attribute.color(new_color))
    end

    def hue!(new_hue)
      write_state(HueConference::Attribute.hue(new_hue))
    end

    def brightness!(factor)
      write_state(HueConference::Attribute.brightness(factor))
    end

    def saturation!(factor)
      write_state(HueConference::Attribute.saturation(factor))
    end

    def blink!(new_state)
      state = new_state ? 'lselect' : 'none'
      write_state(HueConference::Attribute.alert(state))
    end

    def colorloop!(new_state)
      state = new_state ? 'colorloop' : 'none'
      write_state(HueConference::Attribute.effect(state))
    end

    def transition!(seconds)
      write_state(HueConference::Attribute.transitiontime(seconds))
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

