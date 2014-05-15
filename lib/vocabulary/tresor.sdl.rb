type :status

status :draft
status :approved
status :deleted

service_properties do
  status
  integer :provider_id
end