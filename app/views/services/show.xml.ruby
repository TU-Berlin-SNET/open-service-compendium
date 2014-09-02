exporter = BrokerXMLServiceExporter.new

builder = Nokogiri::XML::Builder.new do |xml|
  exporter.build_service(@service, xml)
end

builder.to_xml