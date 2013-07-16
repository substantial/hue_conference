class HueConference::Light
  attr_reader :name, :id
  attr_accessor :client

  def initialize(id, properties = {})
    @id = id
    @name = properties['name']
  end

end
