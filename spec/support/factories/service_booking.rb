FactoryGirl.define do
  factory :service_booking do
    endpoint_url 'http://www.cloud-tresor.de'
    callback_url 'http://market.place/bookings'

    association :service, factory: :immediately_bookable_service
    client

    factory :booking_service_booking do
      booking_status :booking
      booking_time { Time.new }

      factory :booked_service_booking do
        booking_status :booked
        booked_time { Time.new }

        factory :canceling_service_booking do
          booking_status :canceling
          canceling_time { Time.new }

          factory :canceled_service_booking do
            booking_status :canceled
            canceled_time { Time.new }
          end

          factory :canceling_failed_service_booking do
            booking_status :canceling_failed
            canceling_failed_time { Time.new }

            failed_reason 'Could not reach service backend.'
          end
        end

        factory :locked_service_booking do
          booking_status :locked
          locked_time { Time.new }
        end
      end

      factory :booking_failed_service_booking do
        booking_status :booking_failed
        booking_failed_time { Time.new }

        failed_reason 'Could not reach service backend.'
      end
    end
  end
end