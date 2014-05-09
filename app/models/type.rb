class SDL::Base::Type
  class << self
    def class_definition_string(sym, superclass)
      "class SDL::Base::Type::#{sym.to_s.camelize} < #{superclass.name}
        unless @registered
          include SDL::Types::SDLType
          include Mongoid::Document

          embedded_in :#{sym.to_s.underscore}, polymorphic: true

          field :identifier, type: Symbol

          wraps self
          codes local_name.underscore.to_sym

          superclass.subtypes << self

          def ==(other)
            if other.is_a? SDL::Base::Type
              attributes.except('_id') == other.attributes.except('_id')
            else
              false
            end
          end

          @registered = true
        end
      end"
    end

    def add_property_getter(sym, type)

    end

    def add_property_setters(sym, type, multi)
      if multi
        embeds_many sym, as: type.name.demodulize.pluralize.underscore.to_sym, class_name: type.name, inverse_of: nil
      else
        embeds_one sym, as: type.name.demodulize.underscore.to_sym, class_name: type.name, inverse_of: nil
      end
    end
  end

  def set_sdl_property(property, value)
    if property.simple_type?
      v = property.type.new
      v.raw_value = value
      v.initialize_value

      send "#{property.name}=", v
    else
      send "#{property.name}=", value
    end
  end

  def get_sdl_value(property)
    send property.name
  end
end