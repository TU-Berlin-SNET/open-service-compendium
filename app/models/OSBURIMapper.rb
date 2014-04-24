class OSBURIMapper
  def self.uri(object)
    base_url = ApplicationController.class_variable_get(:@@current_request).base_url

    case object
      when SDL::Base::Type.class
        "#{base_url}/types/#{object.local_name}"
      when SDL::Base::Type
        if object.identifier
          "#{object.class.uri}/#{object.identifier.to_s}"
        else
          "#{object.parent.uri}/#{object.class.local_name}/#{object.parent_index}"
        end
      when SDL::Base::Fact
        "#{object.service.uri}/#{object.class.local_name.underscore}/#{object.parent_index}"
      when SDL::Base::Service
        base_url + '/service/' + object.symbolic_name
      else
        raise "Cannot infer URI of object: #{object}"
    end
  end
end