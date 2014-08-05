class ClientsController < ApplicationController
  resource_description do
    short 'Service Broker Clients'
  end

  respond_to :xml

  api :GET, 'clients', 'Returns a list of all clients known to the broker.'
  formats ['xml']
  description <<-END
    # Example Response
    ~~~ xml
    <?xml version="1.0"?>
    <clients count="3">
      <client url="http://192.168.147.145:3000/clients/be21c819-6bc7-4c09-b565-0ce72048b25c">
        <client_profile><![CDATA[PROFILE]]></client_profile>
        <client_data><![CDATA[DATA]]></client_data>
      </client>
      <client url="http://192.168.147.145:3000/clients/08091a55-dd99-4e8f-a11a-0dc7ce7a2d31">
        <client_profile><![CDATA[PROFILE]]></client_profile>
        <client_data><![CDATA[DATA]]></client_data>
      </client>
      <client url="http://192.168.147.145:3000/clients/ed4c2db1-7642-4caf-88cd-706f05cae2fe">
        <client_profile><![CDATA[PROFILE]]></client_profile>
        <client_data><![CDATA[DATA]]></client_data>
      </client>
    </clients>
    ~~~
  END
  def index
    @clients = Client.all
  end

  def show

  end

  def create

  end

  def update

  end

  def delete

  end
end