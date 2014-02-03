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

      sdl_example_dir = Rails.root.join('lib', 'sdl-ng', 'examples').to_s

      # Load SDL
      compendium.load_vocabulary_from_path sdl_example_dir

      # Load Service Definitions
      compendium.load_service_from_path sdl_example_dir, ignore_errors: true

      Rails.logger.info "Loaded compendium with #{compendium.services.count} services."

      compendium
    end
end