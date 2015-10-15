# Load the application and all libraries (including the
# unmodified SDL-NG)
Rails.application.eager_load!

to_prepare = Proc.new do
  # Load all extensions to the SDL-NG
  Dir.glob(File.join(Rails.root, 'lib', 'sdl-ng-overrides', '**', '*.rb')).each do |file|
    load file
  end

  #Set default host
  Rails.application.routes.default_url_options = {:host => 'http://www.open-service-compendium.org'}

  register_uri_mapper = lambda do
    require_dependency File.join(Rails.root, 'app', 'models', 'OSBURIMapper.rb')

    OSBURIMapper.instance_eval do
      include Rails.application.routes.url_helpers
    end

    [SDL::Base::Type, SDL::Base::Type.class].each do |klass|
      klass.class_eval do
        def uri_mapper
          OSBURIMapper
        end
      end
    end
  end

  register_uri_mapper.call

  SDL::Types.eager_load!

  register_uri_mapper.call

  class OpenServiceBroker::Application
    attr_accessor :compendium
  end

  SDL::Types::SDLSimpleType.descendants.each do |type|
    type.instance_eval do
      include Mongoid::Document

      embedded_in name.demodulize.underscore.to_sym, polymorphic: true

      field :serialized_value, type: BSON::Binary
      field :serialized_class, type: String

      after_build do |document|
        document.initialize_value if document.serialized_value
      end

      after_find do |document|
        document.initialize_value if document.serialized_value
      end
    end
  end

  compendium = SDL::Base::ServiceCompendium.new

  sdl_example_dir = Rails.root.join('lib', 'sdl-ng', 'examples')

  # Load example SDL
  compendium.load_vocabulary_from_path sdl_example_dir.join('vocabulary').to_s

  # Load broker vocabulary
  compendium.load_vocabulary_from_path Rails.root.join('lib', 'vocabulary').to_s

  # Load RDF mappings
  Dir[sdl_example_dir.join('rdf_mappers', '*.rb').to_s].each do |file|
    load file

    Rails.logger.info "Loaded RDF mapper from #{file}"
  end

  Rails.logger.info "Loaded compendium."

  Rails.application.compendium = compendium

  Service = SDL::Base::Type::Service

  ClientProfile.initialize_for_sdl
end

unless Rails.configuration.cache_classes
  ActionDispatch::Reloader.to_prepare do
    to_prepare.call
  end
else
  to_prepare.call
end