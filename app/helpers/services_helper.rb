module ServicesHelper
  def render_value(value)
    if value.class < SDL::Types::SDLSimpleType
      render :partial => "value_#{value.class.to_s.demodulize.underscore}", :locals => {:value => value}
    elsif value.class < SDL::Base::Type
      if value.identifier
        value.documentation
      else
        '<table>' + render( :partial => 'services/properties', :locals => {:holder => value}) + '</table>'
      end
    else
      "I don't know, how to render #{value.class}."
    end
  end

  def form_path
    if @service then
      service_path(@service.symbolic_name)
    else
      services_path
    end
  end
end
