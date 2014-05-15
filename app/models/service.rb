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

  def slug
    "#{_id}-#{name}"
  end

  def prepare_historic_record(original_attributes)
    original_attributes.delete('_type')
    original_attributes.delete('_id')
    original_attributes['valid_from'] = original_attributes['updated_at']
    %w(updated_at created_at).each do |key| original_attributes[key] = nil end
    original_attributes['valid_until'] = Time.now

    historical_record = HistoricalServiceRecord.new(original_attributes)
    historical_record._id = {
        '_id' => _id,
        '_version' => _version
    }

    historical_record
  end

  def archive_and_save!(original_attributes)
    historical_service_record = prepare_historic_record(original_attributes)
    historical_service_record.save!

    self._version += 1

    save!
  end

  def delete_and_archive!
    # Duplicate attributes and insert historic version information
    historical_service_record = prepare_historic_record(attributes.deep_dup)
    historical_service_record.deleted = true
    historical_service_record.save!

    delete
  end

  alias :to_param :slug
end