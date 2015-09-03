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
end