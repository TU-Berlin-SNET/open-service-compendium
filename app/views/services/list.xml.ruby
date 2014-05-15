Nokogiri::XML::Builder.new do |xml|
  xml.services(
      'xmlns' => 'http://www.open-service-compendium.org',
      'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
      'xsi:schemaLocation' => xml_schema_url) do
    @services.each do |service|
      @exporter ||= SDL::Exporters::XMLServiceExporter.new

      @exporter.build_service(service, xml)
    end
  end
end.to_xml