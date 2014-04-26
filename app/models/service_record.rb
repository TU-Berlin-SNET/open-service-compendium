class ServiceRecord
  module FieldDefinitions
    def self.included(clazz)
      clazz.instance_eval do
        field :_id, type: String, default: -> { new_id }
        field :_version, type: Integer, default: 1
        field :name, type: String, default: 'untitled'
        field :sdl_parts, type: Hash, default: {}
      end
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
  end

  include Mongoid::Document
  include Mongoid::Timestamps

  include FieldDefinitions

  ID_BASE = Radix::Base.new(Radix::BASE::B62 + ['_'])

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

  def uri
    "mongodb://service_records/#{_id}"
  end

  def slug
    "#{_id}-#{name}"
  end

  def archive_and_save!
    if changed?
      HistoricalServiceRecord.create(
          _id: _id,
          _version: _version,
          name: name_was,
          sdl_parts: sdl_parts_was,
          valid_from: updated_at,
          valid_until: Time.now
      )

      self._version += 1

      save!
    end
  end

  alias :to_param :slug
end