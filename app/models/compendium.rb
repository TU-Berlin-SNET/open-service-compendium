class SDL::Base::ServiceCompendium
  def mongo_id_service_map
    @mongo_id_service_map ||= {}
  end

  def approved_services
    services.select do |name, service|
      service.status.status.identifier == :approved
    end
  end
end