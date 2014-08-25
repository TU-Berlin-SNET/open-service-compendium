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
          service.sdl_parts['meta'] = "status #{status}\nprovider_id '123'"

          service.load_service_from_sdl
        end
      end
    end

    trait :with_older_versions do
      after(:create) do |service|
        %w[approved draft draft approved draft approved draft].each_with_index do |status, index|
          older_service = Service.new(
            service_id: service.service_id,
            sdl_parts: service.sdl_parts,
            created_at: Time.now - ((index + 1) * 60 * 60),
            updated_at: Time.now - ((index + 1) * 60 * 60),
            service_deleted: service.service_deleted?
          )

          older_service.sdl_parts['meta'].gsub!(/(status )(\w+)/, "\\1#{status}")

          older_service.load_service_from_sdl

          older_service.timeless.save!
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

    factory :immediately_bookable_service do
      sdl_parts {
        {
            'meta' => 'status approved',
            'main' => 'immediate_booking "http://www.cloud-tresor.de"'
        }
      }
    end

    trait :deleted do
      service_deleted true
    end

    after(:build) do |service|
      service.load_service_from_sdl
    end
  end
end