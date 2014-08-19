require 'spec_helper'

describe 'services/show.xml.ruby' do
  it 'renders the version url as separate attribute' do
    service = create(:approved_service, :with_older_versions)

    assign(:service, service)

    render

    expect {
      @xml = Nokogiri::XML(rendered)
    }.not_to raise_exception

    expect(@xml.root.name).to eq 'service'

    expect(@xml.xpath('//@service_version_url').first.value).to eq version_service_url(service.service_id, service._id)
  end
end