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

    expect(@xml.xpath('//@uri').first.value).to eq version_service_url(service.service_id, service._id)
  end

  it 'renders the service_uuid and version_uuid as separate attribute' do
    service = create(:approved_service, :with_older_versions)

    assign(:service, service)

    render

    expect {
      @xml = Nokogiri::XML(rendered)
    }.not_to raise_exception

    expect(@xml.root.name).to eq 'service'

    expect(@xml.at_xpath('//@service_uuid').value).to eq service.service_id
    expect(@xml.at_xpath('//@version_uuid').value).to eq service._id
  end
end

describe 'services/list_versions.xml.nokogiri' do
  it 'renders all service versions' do
    service = create(:approved_service, :with_older_versions)
    versions = Service.versions(service.service_id)

    assign(:versions, versions)

    render

    expect {
      @xml = Nokogiri::XML(rendered)
    }.not_to raise_exception

    expect(@xml.root.name).to eq 'versions'
    expect(@xml.at_xpath('//@count').value).to eq versions.count.to_s
    expect(@xml.at_xpath('//@service_url').value).to eq service_url(service.service_id)
    expect(@xml.at_xpath('//@service_uuid').value).to eq service.service_id

    versions.each do |version|
      expect(@xml.at_xpath("//version[@version_uuid = '#{version._id}']/@url").value).to eq version_service_url(service.service_id, version._id)
    end
  end
end