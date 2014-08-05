class HistoricalServiceRecord < SDL::Base::Type
  class << self
    def additional_field_definitions
      field :_id, type: Hash
      field :valid_from, type: Time
      field :valid_until, type: Time
      field :service_deleted, type: Boolean, default: false

      store_in collection: "historical_service_records"
    end
  end

  def uri
    "mongodb://historical_service_records/#{_id}/versions/#{_version}"
  end

  def updated_at
    valid_until
  end

  def cache_key
    return "#{model_key}/new" if new_record?
    return "#{model_key}/#{_id['_id']}-#{_id['_version']}-#{updated_at.utc.to_s(:number)}" if do_or_do_not(:updated_at)
    "#{model_key}/#{_id['_id']}-#{_id['_version']}"
  end
end