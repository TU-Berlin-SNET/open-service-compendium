require 'yaml'

namespace :tresor do
  task setup_logger: :environment do
    logger           = Logger.new(STDOUT)
    logger.level     = Logger::INFO
    Rails.logger     = logger
  end

  desc "Resets the database and populates with SDL-NG examples"

  task :reset_and_load_examples => :setup_logger do
    Rails.logger.info("Deleting all services")

    Service.delete_all

    service_files = Dir.glob(File.join(Rails.root, 'lib', 'sdl-ng', 'examples', 'services', '**', '*.service.rb'))

    Rails.logger.info("Loading #{service_files.count} services")

    this_path = Pathname(Dir.pwd)

    service_files.each_with_index do |file, index|
      Rails.logger.info("Loading #{index + 1} / #{service_files.count}: #{Pathname(file).relative_path_from(this_path)}")
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
end