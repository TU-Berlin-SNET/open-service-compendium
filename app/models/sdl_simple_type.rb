class SDL::Types::SDLSimpleType
  def raw_value=(value)
    @raw_value = value

    self.serialized_class = value.class.name
    self.serialized_value = value.mongoize
  end

  def raw_value
    @raw_value ||= Object.const_get(serialized_class).demongoize(self.serialized_value)
  end
end