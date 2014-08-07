require 'spec_helper'

describe 'providers/index' do
  include_context 'with existing providers'
  
  it 'gives out an xml document with all providers' do
    assign(:providers, Provider.all)

    render

    expect {
      @xml = Nokogiri::XML(rendered)
    }.not_to raise_exception

    expect(@xml.root.name).to eq 'providers'

    Provider.all.each do |provider|
      expect(@xml.xpath("/providers/provider[@url = '#{provider_url(provider)}']")).to have_exactly(1).node
    end
  end
end

describe 'providers/show' do
  include_context 'with existing providers'

  it 'gives out an xml document with a specific provider' do
    assign(:provider, Provider.first)

    render

    expect {
      @xml = Nokogiri::XML(rendered)
    }.not_to raise_exception

    expect(@xml.root.name).to eq 'provider'

    expect(@xml.xpath('/provider/@url').first.value).to eq provider_url(Provider.first)
  end
end