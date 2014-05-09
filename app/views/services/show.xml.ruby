exporter = SDL::Exporters::XMLServiceExporter.new

builder = Nokogiri::XML::Builder.new do |xml|
  exporter.build_service(@service, xml)
end

builder.doc.root['xmlns:xsi'] = 'http://www.w3.org/2001/XMLSchema-instance'
builder.doc.root['xsi:schemaLocation'] = xml_schema_url

builder.to_xml