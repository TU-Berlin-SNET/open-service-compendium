FactoryGirl.define do
  sequence :service_name do |n|
    "service-#{n.humanize}"
  end

  factory :service_record do
    name { generate (:service_name) }
    sdl_parts {
      {'main' => "has_name '#{name}'"}
    }

    %w(draft submitted approved).each do |status|
      factory "#{status}_record" do
        after(:build) do |record|
          record.sdl_parts['meta'] = "status #{status}\nprovider_id 123"
        end
      end
    end
  end

  factory :service_record_with_history, parent: :service_record do
    after(:create) do |service_record|
      3.times do
        service_record.name = generate(:service_name)
        service_record.archive_and_save!
      end
    end
  end
end