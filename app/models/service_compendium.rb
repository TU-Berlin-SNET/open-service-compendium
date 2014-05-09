class SDL::Base::ServiceCompendium
  def post_process_service(sym, receiver)
    receiver.service
  end

  def approved_services
    services.select do |name, service|
      service.status && (service.status.status.identifier == :approved)
    end
  end
end