FactoryGirl.define do
  factory :client do
    client_profile 'lorem_ipsum'
    client_data '<?xml version="1.0"?><client/>'

    trait :with_bookings do
      after(:create) do |client, evaluator|
        ServiceBooking::STATUSES.each do |status|
          client.service_bookings << FactoryGirl.create("#{status}_service_booking")
        end
      end
    end
  end
end