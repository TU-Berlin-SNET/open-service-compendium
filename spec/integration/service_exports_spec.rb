require 'spec_helper'

describe 'When exporting services' do
  describe 'as an xml export' do
    it 'conforms to a retrievable XML Schema definition' do
      service = create(:google_drive_service)

      service.save

      get "/services/#{service.service_id}.xml"

      service_xml = response.body

      expect {
        @xml = Nokogiri::XML(service_xml)
      }.not_to raise_exception

      schema_uri = URI(@xml.xpath('//@xsi:schemaLocation').first.value)

      get schema_uri.path

      expect {
        @schema = Nokogiri::XML::Schema(response.body)
      }.not_to raise_exception

      errors = @schema.validate(@xml)

      expect(errors).to be_empty
    end
  end
end