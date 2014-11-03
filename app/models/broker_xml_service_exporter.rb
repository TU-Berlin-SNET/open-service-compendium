class BrokerXMLServiceExporter < SDL::Exporters::XMLServiceExporter
  def service_xml_attributes(service)
    self.class.instance_eval do
      unless @url_helpers
        include Rails.application.routes.url_helpers
      end
    end

    super(service).merge ({
      'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
      'xsi:schemaLocation' => xml_schema_path,
      'service_uuid' => service.service_id,
      'version_uuid' => service._id
    })
  end
end