exporter = BrokerXMLServiceExporter.new

builder = Nokogiri::XML::Builder.new do |xml|
  exporter.build_service(@service, xml)
end

service = builder.doc.xpath('//osc:service', {:osc => 'http://www.open-service-compendium.org'})[0]

%w[uri schemaLocation].each do |attribute|
  service.attributes[attribute].value = "#{request.scheme}://#{request.host}#{service.attributes[attribute].value}"
end

builder.to_xml