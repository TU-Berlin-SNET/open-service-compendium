class ServiceBooking
  include Mongoid::Document
  include Mongoid::Enum

  field :_id, type: String, default: ->{ SecureRandom.uuid }

  field :callback_url, type: String
  field :endpoint_url, type: String
  field :failed_reason, type: String

  STATUSES = [:booking, :booking_failed, :booked, :canceling, :canceling_failed, :canceled, :locked]

  enum :booking_status, STATUSES, default: :booking

  STATUSES.each do |sym|
    field "#{sym}_time".to_sym, type: Time
  end

  belongs_to :client
  belongs_to :service

  validates_presence_of :client, :service
end