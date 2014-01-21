register_uri_mapper = lambda do
  require_dependency File.join(Rails.root, 'app', 'models', 'OSBURIMapper.rb')

  [SDL::Base::Type, SDL::Base::Type.class, SDL::Base::Service].each do |klass|
    klass.class_eval do
      def uri_mapper
        OSBURIMapper
      end
    end
  end
end

register_uri_mapper.call

unless Rails.configuration.cache_classes
  ActionDispatch::Reloader.to_prepare do
    Rails.application.instance_variable_set '@compendium'.to_sym, nil

    SDL::Types.eager_load!

    register_uri_mapper.call
  end
end

class OpenServiceBroker::Application
  def compendium
    @compendium ||= build_compendium
  end

  protected
    def build_compendium
      compendium = SDL::Base::ServiceCompendium.new

      sdl_lib_dir = Rails.root.join('lib', 'sdl-ng').to_s

      # Load SDL
      Dir.glob(File.join(sdl_lib_dir, 'examples', '**', '*.sdl.rb')) do |filename|
        compendium.facts_definition do
          eval(File.read(filename), binding, filename)
        end
      end

      # Load Service Definitions
      Dir.glob(File.join(sdl_lib_dir, 'examples', '**', '*.service.rb')) do |filename|
        compendium.service filename.match(%r[.+/(.+).service.rb])[1] do
          eval(File.read(filename), binding, filename)
        end
      end

      Rails.logger.info "Loaded compendium with #{compendium.services.count} services."

      compendium
    end
end