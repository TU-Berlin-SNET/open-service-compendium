class ServiceRecord
  include Mongoid::Document

  SLUG_BASE = Radix::Base.new(Radix::BASE::B62 + ['-', '_'])

  field :_id, type: String, default: -> { new_slug }
  field :name, type: String, default: 'untitled'
  field :sdl_parts, type: Hash, default: {}

  def new_slug
    SLUG_BASE.convert(rand(2**48), 10)
  end

  def to_service_sdl
    sdl = StringIO.new

    sdl_parts.each do |key, part|
      sdl.puts "#BEGIN #{key}"
      sdl.puts part
      sdl.puts "#END #{key}"
    end

    sdl.string
  end

  def load_into(compendium)
    service = compendium.load_service_from_string(to_service_sdl, name, uri)

    service._id = _id
    service.sdl_parts = sdl_parts
  end

  def unload_from(compendium)
    compendium.services[uri] = nil
  end

  def uri
    "#{ApplicationController.class_variable_get(:@@current_request).base_url}/service/#{slug}-#{name}"
  end

  def slug
    _id
  end
end