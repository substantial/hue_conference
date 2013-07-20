# Beat Lights
# Require jruby and use ruby-processing gem

class BeatLights < Processing::App
  # Load minim and import the packages we'll be using
  load_library "minim"
  import "ddf.minim"
  import "ddf.minim.analysis"

  def setup
    smooth  # smoother == prettier
    size(1280,100)  # let's pick a more interesting size

    background 10  # ...and a darker background color
    @minim = Minim.new(self)
    @beat = BeatDetect.new
    @beat.detect_mode(BeatDetect::FREQ_ENERGY)
    @beat.set_sensitivity(200)
    @input = @minim.get_line_in

    p "setup finished"
  end

  def draw
    # nothing here yet...
    @beat.detect(@input.left)
    File.open('beat_output', "w+") do |file|
      if @beat.is_kick
        file.puts "BEAT!"
        puts "beat"
      end
    end
  end
end

BeatLights.new :title => "Beat Lights"

