class SDL::Base::Type::Service
  include SDL::Types::SDLType
  include Mongoid::Document
  include ActiveSupport::Inflector

  include Mongoid::Timestamps
  include ServiceFieldDefinitions

  field :_id, type: String, default: -> { new_id }
  field :identifier, type: Symbol

  wraps self
  codes local_name.underscore.to_sym

  superclass.subtypes << self

  @registered = true

  scope :with_status, ->(status) do where('status.identifier' => status) end

  ID_BASE = Radix::Base.new(Radix::BASE::B62 + ['_'])

  def new_id
    ID_BASE.convert(rand(2**122), 10)
  end

  def historical_records
    HistoricalServiceRecord.where('_id._id' => _id)
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
          _id: {
              '_id' => _id,
              '_version' => _version
          },
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