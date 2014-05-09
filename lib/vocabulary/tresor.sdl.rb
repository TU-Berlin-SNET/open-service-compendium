type :status

status :draft
status :submitted
status :approved

service_properties do
  status
  integer :provider_id
end