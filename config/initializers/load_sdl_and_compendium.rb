Rails.application.eager_load!

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

      # Load example SDL
      compendium.load_vocabulary_from_path sdl_example_dir

      # Load broker vocabulary
      compendium.load_vocabulary_from_path Rails.root.join('lib', 'vocabulary').to_s

      # Load Service Definitions
      ServiceRecord.each do |record|
        record.load_into compendium
      end

      Rails.logger.info "Loaded compendium with #{compendium.services.count} services."

      compendium
    end
end