module ServiceFieldDefinitions
  def self.included(clazz)
    clazz.instance_eval do
      field :_version, type: Integer, default: 1
      field :name, type: String, default: 'untitled'
      field :sdl_parts, type: Hash, default: {}
    end
  end

  def to_service_sdl
    combine_service_sdl_parts sdl_parts
  end

  def combine_service_sdl_parts(sdl_parts)
    sdl = StringIO.new

    sdl_parts.each do |key, part|
      sdl.puts "#BEGIN #{key}"
      sdl.puts part
      sdl.puts "#END #{key}"
    end

    sdl.string
  end

  def load_service_from_sdl
    receiver = SDL::Receivers::TypeInstanceReceiver.new(self)

    receiver.instance_eval to_service_sdl
  end

  def unload

  end
end