class ServiceRecord
  include Mongoid::Document

  ID_BASE = Radix::Base.new(Radix::BASE::B62 + ['_'])

  field :_id, type: String, default: -> { new_id }
  field :name, type: String, default: 'untitled'
  field :sdl_parts, type: Hash, default: {}
  field :versions, type: Array, default: []

  validates_presence_of [:name]

  attr_accessor :service
  attr_accessor :compendium

  def new_id
    ID_BASE.convert(rand(2**122), 10)
  end

  def self.combine_service_sdl_parts(sdl_parts)
    sdl = StringIO.new

    sdl_parts.each do |key, part|
      sdl.puts "#BEGIN #{key}"
      sdl.puts part
      sdl.puts "#END #{key}"
    end

    sdl.string
  end

  def to_service_sdl
    self.class.combine_service_sdl_parts sdl_parts
  end

  def load_into(compendium)
    @compendium = compendium

    service = compendium.load_service_from_string(to_service_sdl, name, uri)

    @service = service

    service._id = _id
    service.sdl_parts = sdl_parts

    compendium.mongo_id_service_map[_id] = WeakRef.new(service)
  end

  def unload
    compendium.services[uri] = nil
  end

  def uri
    "mongodb://service_records/#{_id}"
  end

  def slug
    "#{_id}-#{name}"
  end

  alias :to_param :slug
end