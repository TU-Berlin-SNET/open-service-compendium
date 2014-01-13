module ServicesHelper
  def render_value(value)
    if value.class < SDL::Types::SDLSimpleType
      render :partial => "value_#{value.class.to_s.demodulize.underscore}", :locals => {:value => value}
    elsif value.class < SDL::Base::Type
      '<table>' + render( :partial => 'services/type', :locals => {:type => value}) + '</table>'
    elsif value.class.eql? Array
      value.map do |item| render_value item end.join('')
    else
      "I don't know, how to render #{value.class}."
    end
  end
end
