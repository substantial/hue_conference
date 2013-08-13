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
    # @beat.detect_mode(BeatDetect::FREQ_ENERGY)
    @beat.detect_mode(BeatDetect::SOUND_ENERGY)
    @beat.set_sensitivity(100)
    @input = @minim.get_line_in

    puts "setup finished"
  end

  def draw
    @beat.detect(@input.left)
    puts "beat #{Time.now}" if @beat.isOnset
    # puts "beat #{Time.now}" if @beat.isKick
  end
end

BeatLights.new :title => "Beat Lights"

