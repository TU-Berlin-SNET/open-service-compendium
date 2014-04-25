class SDL::Base::Service
  # MongoDB record id
  attr_accessor :_id

  # MongoDB sdl_parts
  attr_accessor :sdl_parts

  def to_service_sdl
    ServiceRecord.combine_service_sdl_parts(sdl_parts)
  end
end