Rails.application.eager_load!

register_uri_mapper = lambda do
  require_dependency File.join(Rails.root, 'app', 'models', 'OSBURIMapper.rb')

  [SDL::Base::Type, SDL::Base::Type.class].each do |klass|
    klass.class_eval do
      def uri_mapper
        OSBURIMapper
      end
    end
  end
end

register_uri_mapper.call

class OpenServiceBroker::Application
  attr_accessor :compendium
end

SDL::Types::SDLSimpleType.descendants.each do |type|
  type.instance_eval do
    include Mongoid::Document

    embedded_in name.demodulize.underscore.to_sym, polymorphic: true

    field :raw_value, type: Object

    after_build do |document|
      document.initialize_value if document.raw_value
    end

    after_find do |document|
      document.initialize_value if document.raw_value
    end
  end
end

compendium = SDL::Base::ServiceCompendium.new

sdl_example_dir = Rails.root.join('lib', 'sdl-ng', 'examples').to_s

# Load example SDL
compendium.load_vocabulary_from_path sdl_example_dir

# Load broker vocabulary
compendium.load_vocabulary_from_path Rails.root.join('lib', 'vocabulary').to_s

Rails.logger.info "Loaded compendium."

Rails.application.compendium = compendium

Service = SDL::Base::Type::Service