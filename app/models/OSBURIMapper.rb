class OSBURIMapper
  def self.uri(object)
    case object
      when SDL::Base::Type::Service
        self.new.version_service_url(object.service_id, object._id)
      when SDL::Base::Type.class
        "#{base_url}/types/#{object.local_name}"
      when SDL::Base::Type
        if object.identifier
          "#{object.class.uri}/#{object.identifier.to_s}"
        else
          "#{object.parent.uri}/#{object.class.local_name}/#{object.parent_index}"
        end
      else
        raise "Cannot infer URI of object: #{object}"
    end
  end
end