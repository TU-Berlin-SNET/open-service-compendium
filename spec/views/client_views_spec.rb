require 'spec_helper'

describe 'clients/index' do
  include_context 'with existing clients'
  
  it 'gives out an xml document with all clients' do
    assign(:clients, Client.all)

    render

    expect {
      @xml = Nokogiri::XML(rendered)
    }.not_to raise_exception

    expect(@xml.root.name).to eq 'clients'

    Client.all.each do |client|
      expect(@xml.xpath("/clients/client[@url = '#{client_url(client)}']")).to have_exactly(1).node
    end
  end
end

describe 'clients/show' do
  include_context 'with existing clients'

  it 'gives out an xml document with a specific client' do
    assign(:client, Client.first)

    render

    expect {
      @xml = Nokogiri::XML(rendered)
    }.not_to raise_exception

    expect(@xml.root.name).to eq 'client'

    expect(@xml.xpath('/client/@url').first.value).to eq client_url(Client.first)
  end
end