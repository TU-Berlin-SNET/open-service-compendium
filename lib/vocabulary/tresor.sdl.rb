type :status

status :draft
status :submitted
status :approved

fact :status do
  status
end

fact :provider_id do
  integer :provider_id
end