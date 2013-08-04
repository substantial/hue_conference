module HueConference

  class FloatOutOfRange < Exception; end

  module LightOptions
    MAX_BRIGHTNESS = 255
    MAX_SATURATION = 255
    MAX_HUE = 65536

    def on(new_state)
      { on: new_state }
    end

    def hue(new_hue)
      invalid = new_hue > MAX_HUE || new_hue < 0
      raise OutOfRange, "Value must be integer between 0 - #{MAX_HUE}" if invalid
      { hue: new_hue }
    end

    def color(new_color)
      hsl = new_color.to_hsl
      {
        bri: (hsl.l * MAX_BRIGHTNESS).round,
        sat: (hsl.s * MAX_SATURATION).round,
        hue: (hsl.h * MAX_HUE).round,
        transitiontime: 1
      }
    end

    def saturation(factor)
      validate_factor(factor)
      { sat: (MAX_SATURATION * factor).round }
    end

    def brightness(factor)
      validate_factor(factor)
      { bri: (MAX_BRIGHTNESS * factor).round }
    end

    def validate_factor(factor)
      invalid = (factor < 0.0 || factor > 1.0)
      raise FloatOutOfRange, "Number must be between 0.0 to 1.0" if invalid
    end
  end
end
