require 'spec_helper'

describe 'When exporting services' do
  describe 'as an xml export' do
    it 'conforms to a retrievable XML Schema definition' do
      service = create(:google_drive_service)

      service.save

      get "/services/#{service._id}.xml"

      pending :not_implemented
    end
  end
end