class HistoricalServiceRecordSerializer < ActiveModel::Serializer
  cached

  delegate :cache_key, to: :object

  attributes :url, :valid_from, :valid_until, :deleted

  def url
    historical_service_url(object._id['_id'], object._version)
  end
end