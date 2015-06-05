require 'yaml'

namespace :tresor do
  desc "Resets the database and populates with SDL-NG examples"

  task :reset_and_load_examples => :environment do
    Service.delete_all

    Dir.glob(File.join(Rails.root, 'lib', 'sdl-ng', 'examples', 'services', '**', '*.service.rb')).each do |file|
      begin
        s = Service.create(
            name: file.match(/(\w+).service.rb/)[1],
            sdl_parts: {
                'meta' => 'status approved',
                'main' => File.read(file)
            }
        )
        s.load_service_from_sdl(file)
        s.save!
      rescue Exception => e
        puts "Could not load service from #{file}: #{e.message}"
      end
    end
  end

  desc "Setup for the TRESOR development environment. Creates clients, some applications (including the broker), and
        creates policies for these applications"
  task :setup_environment => :environment do |t, args|
    Resque.inline = true

    Settings.pdp_username = ENV['PDP_USERNAME'] if ENV['PDP_USERNAME']
    Settings.pdp_password = ENV['PDP_PASSWORD'] if ENV['PDP_PASSWORD']

    organization_uuid_hash_file = if ENV['ORGANIZATION_UUID_HASH_FILE']
                                    File.new(ENV['ORGANIZATION_UUID_HASH_FILE'])
                                  else
                                    File.new(File.join(Rails.root, 'lib', 'tasks', 'organization_uuids.yml'))
                                  end

    organization_uuid_hash = YAML.load(organization_uuid_hash_file)

    [Service, ServiceBooking, Client].map &:delete_all

    Settings.demo_services.each do |symbolic_name, args|
      service = Service.new(
          :name => symbolic_name,
          :sdl_parts => {
              'meta' => 'status approved',
              'main' => ["service_name '#{args[:name]}'", "immediate_booking '#{args[:url]}'"].join("\r\n")
          }
      )
      service.load_service_from_sdl
      service.service_id = args[:uuid] if args[:uuid]
      service.save!
    end

    organization_uuid_hash.each do |organization, uuid|
      organization = Client.create!(
          :_id => uuid,
          :tresor_organization => organization,
      )

      Service.each do |service|
        booking = ServiceBooking.create(
            client_id: organization._id,
            service_id: service._id,
            booking_time: Time.new,
            callback_url: nil)

        Resque.enqueue(BookingWorker, nil, booking._id, 'book')

        Resque.enqueue(PolicyUploadWorker, 'allow_all', service.service_id, organization._id, nil)
      end
    end
  end
end