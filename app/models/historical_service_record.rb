class HistoricalServiceRecord
  include Mongoid::Document

  include ServiceRecord::FieldDefinitions

  field :_id, type: Hash
  field :valid_from, type: Time
  field :valid_until, type: Time
  field :deleted, type: Boolean, default: false

  def uri
    "mongodb://historical_service_records/#{_id}/versions/#{_version}"
  end
end