class BrokerXSDSchemaExporter < SDL::Exporters::XSDSchemaExporter
  def build_service_attributes(xml, service_class)
    super(xml, service_class)

    xml['ns'].attribute :name => 'service_uuid', :type => 'UUIDType'
    xml['ns'].attribute :name => 'version_uuid', :type => 'UUIDType'
  end

  def build_additional_types(xml)
    xml['ns'].simpleType :name => 'UUIDType' do
      xml['ns'].restriction :base => 'ns:string' do
        xml['ns'].pattern :value => '[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}'
      end
    end
  end
end