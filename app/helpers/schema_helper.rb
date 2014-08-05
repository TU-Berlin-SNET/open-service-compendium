module SchemaHelper
  def cheat_sheet_link(klass)
    if klass < SDL::Base::Type
      klass.local_name + '_type'
    elsif klass < SDL::Types::SDLSimpleType
      klass.name.demodulize
    end
  end

  def example_value(property)
    if property.type.eql? SDL::Types::SDLString
      "\"#{property.name}\""
    elsif property.type.eql? SDL::Types::SDLNumber
      '42'
    elsif property.type.eql? SDL::Types::SDLUrl
      '"http://www.open-service-compendium.org"'
    else
      example_instances = @compendium.type_instances[property.type].keys

      unless example_instances.empty?
        ":#{example_instances.sample.to_s}"
      else
        ":#{t('cheat_sheet.not_yet_defined')}"
      end
    end
  end
end
