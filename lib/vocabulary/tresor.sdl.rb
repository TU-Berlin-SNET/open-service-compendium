type :status

status :draft
status :approved

type :booking do
  subtype :immediate_booking do
    string :endpoint_url
  end

  subtype :synchronous_booking do
    string :booking_url
  end
end

service_properties do
  status

  integer :provider_id

  string :default_user_group

  immediate_booking
  synchronous_booking
end