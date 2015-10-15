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
          if object._index
            "#{object.parent_object.uri}/#{object.class.local_name}/#{object._index}"
          else
            "#{object.parent_object.uri}/#{object.class.local_name}"
          end
        end
      else
        raise "Cannot infer URI of object: #{object}"
    end
  end

  def self.base_url
    "http://www.open-service-compendium.org"
  end
end