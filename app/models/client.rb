class Client
  include Mongoid::Document

  field :_id, type: String, default: ->{ SecureRandom.uuid }
  field :client_data, type: String
  field :client_profile, type: String

  has_many :service_bookings
end