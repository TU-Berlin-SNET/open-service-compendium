namespace :tresor do
  desc "Resets the database and populates with SDL-NG examples"

  task :reset_and_load_examples => :environment do
    Service.delete_all
    HistoricalServiceRecord.delete_all

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
end