module ServiceFieldDefinitions
  def self.included(clazz)
    clazz.instance_eval do
      include Mongoid::Document
      include Mongoid::Timestamps

      field :_version, type: Integer, default: 1
      field :name, type: String, default: 'untitled'
      field :sdl_parts, type: Hash, default: {}
    end

    field_definitions.each do |block|
      clazz.instance_eval &block
    end

    clazz.additional_field_definitions
  end

  def self.field_definitions
    @field_definitions ||= []
  end

  def to_service_sdl
    combine_service_sdl_parts sdl_parts
  end

  def combine_service_sdl_parts(sdl_parts)
    sdl = StringIO.new

    sdl_parts.each do |key, part|
      sdl << "#BEGIN #{key}\r\n"
      part.lines.each do |line|
        sdl << "#{line}\r\n"
      end
      sdl << "#END #{key}\r\n"
    end

    sdl.string
  end

  def load_service_from_sdl
    self.class.properties.each do |property|
      unless self[property.name].blank?
        self.send "#{property.name}=", nil
      end
    end

    receiver = SDL::Receivers::TypeInstanceReceiver.new(self)

    receiver.instance_eval to_service_sdl
  end

  def unload

  end
end