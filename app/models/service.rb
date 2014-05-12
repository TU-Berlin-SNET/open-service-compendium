class SDL::Base::Type::Service < SDL::Base::Type
  include SDL::Types::SDLType

  include ActiveSupport::Inflector

  class << self
    def add_property_setters(sym, type, multi)
      ServiceFieldDefinitions.field_definitions << Proc.new do
        if multi
          embeds_many sym, as: type.name.demodulize.pluralize.underscore.to_sym, class_name: type.name, inverse_of: nil
        else
          embeds_one sym, as: type.name.demodulize.underscore.to_sym, class_name: type.name, inverse_of: nil
        end
      end
    end

    def additional_field_definitions
      field :_id, type: String, default: -> { new_id }
      field :identifier, type: Symbol

      scope :with_status, ->(status) do where('status.identifier' => status) end

      store_in collection: "service_records"
    end
  end

  wraps self
  codes local_name.underscore.to_sym

  superclass.subtypes << self

  @registered = true

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

  def prepare_historical_attributes
    historic_attributes = attributes.merge(changed_attributes).dup
    historic_attributes['_type'] = 'HistoricalServiceRecord'
    historic_attributes['valid_from'] = historic_attributes['updated_at']
    historic_attributes['_id'] = {
        '_id' => historic_attributes['_id'],
        '_version' => historic_attributes['_version']
    }
    %w(updated_at created_at).each do |key| historic_attributes[key] = nil end
    historic_attributes['valid_until'] = Time.now
    historic_attributes
  end

  def archive_and_save!
    historic_attributes = prepare_historical_attributes

    HistoricalServiceRecord.collection.insert historic_attributes

    self._version += 1

    save!
  end

  def delete_and_archive!
    # Duplicate attributes and insert historic version information
    historic_attributes = prepare_historical_attributes
    historic_attributes['deleted'] = true

    HistoricalServiceRecord.collection.insert historic_attributes

    delete
  end

  alias :to_param :slug
end