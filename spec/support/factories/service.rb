FactoryGirl.define do
  sequence :service_name do |n|
    "service-#{n.humanize}"
  end

  factory :service do
    identifier { generate (:service_name) }
    sdl_parts { {'main' => "service_name '#{identifier}'\r\nservice_tag 'new-tag'"} }

    %w(draft approved).each do |status|
      factory "#{status}_service" do
        after(:build) do |service|
          service.sdl_parts['meta'] = "status #{status}\nprovider_id 123"

          service.load_service_from_sdl
        end
      end
    end

    factory :google_drive_service do
      sdl_parts {
        {
            'meta' => 'status approved',
            'main' => File.read(Rails.root.join('lib', 'sdl-ng', 'examples', 'services', 'google_drive_for_business.service.rb'))
        }
      }
    end

    factory :service_with_history do
      after(:create) do |service|
        3.times do
          original_attributes = service.attributes.deep_dup
          service.identifier = generate(:service_name)
          service.archive_and_save!(original_attributes)
        end
      end
    end

    factory :immediately_bookable_service do
      sdl_parts {
        {
            'meta' => 'status approved',
            'main' => 'immediate_booking "http://www.cloud-tresor.de"'
        }
      }
    end

    after(:build) do |service|
      service.load_service_from_sdl
    end
  end
end