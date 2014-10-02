namespace :tresor do
  desc "Resets the database and populates with SDL-NG examples"

  task :reset_and_load_examples => :environment do
    Service.delete_all

    Dir.glob(File.join(Rails.root, 'lib', 'sdl-ng', 'examples', 'services', '*')).each do |file|
      s = Service.create(
          name: file.match(/(\w+).service.rb/)[1],
          sdl_parts: {
              'meta' => 'status approved',
              'main' => File.read(file)
          }
      )
      s.load_service_from_sdl
      s.save!
    end
  end

  desc "Setup for the TRESOR development environment. Creates clients, some applications (including the broker), and
        creates policies for these applications"

  task :setup_development_environment, [:broker_url, :pdp_url_template] => :environment do |t, args|
    raise "Need to define both broker_url and pdp_url_template" if args.count != 2

    [Service, ServiceBooking, Client].map &:delete_all

    Settings.pdp_url = args[:pdp_url_template]

    Settings.demo_services.each do |symbolic_name, args|
      service = Service.new(
          :name => symbolic_name,
          :sdl_parts => {
              'meta' => 'status approved',
              'main' => ["service_name '#{args[:name]}'", "immediate_booking '#{args[:url]}'"].join("\r\n")
          }
      )
      service.load_service_from_sdl
      service.save!
    end

    %w[MMS HERZ MEDISITE].each do |tresor_organization|
      organization = Client.create!(
          :tresor_organization => tresor_organization
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