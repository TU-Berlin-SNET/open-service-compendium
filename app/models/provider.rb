class Provider
  include Mongoid::Document

  field :_id, type: String, default: ->{ SecureRandom.uuid }
  field :provider_data, type: String
end