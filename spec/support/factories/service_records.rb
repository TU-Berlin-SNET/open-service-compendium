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
          record.sdl_parts['meta'] = "status #{status}"
        end
      end
    end
  end
end