require 'spec_helper'

describe 'clients/index' do
  before :each do
    3.times { create(:client) }
  end

  after :each do
    Client.delete_all
  end

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