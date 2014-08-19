exporter = SDL::Exporters::XMLServiceExporter.new

builder = Nokogiri::XML::Builder.new do |xml|
  exporter.build_service(@service, xml)
end

builder.doc.root['xmlns:xsi'] = 'http://www.w3.org/2001/XMLSchema-instance'
builder.doc.root['xsi:schemaLocation'] = xml_schema_url
builder.doc.root['service_version_url'] = version_service_url(@service.service_id, @service._id)

builder.to_xml