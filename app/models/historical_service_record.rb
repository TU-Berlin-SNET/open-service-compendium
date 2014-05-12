class HistoricalServiceRecord
  class << self
    def additional_field_definitions
      field :_id, type: Hash
      field :valid_from, type: Time
      field :valid_until, type: Time
      field :deleted, type: Boolean, default: false

      store_in collection: "historical_service_records"
    end
  end

  def uri
    "mongodb://historical_service_records/#{_id}/versions/#{_version}"
  end

  def updated_at
    valid_until
  end
end