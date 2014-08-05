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

  api :GET, 'clients/:id', 'Shows a client'
  formats ['xml']
  description <<-END
    # Example Response
    ~~~ xml
    <?xml version="1.0"?>
    <client url="http://192.168.147.145:3000/clients/be21c819-6bc7-4c09-b565-0ce72048b25c">
      <client_profile><![CDATA[PROFILE]]></client_profile>
      <client_data><![CDATA[DATA]]></client_data>
    </client>
    ~~~
  END
  error 404, 'The client does not exist'
  def show
    begin
      @client = Client.find(params[:id])
    rescue Mongoid::Errors::DocumentNotFound
      render text: 'Client not found', status: 404
    end
  end

  api :POST, 'clients', 'Creates a new client'
  param :client_data, String, :desc => 'Arbitrary client data', :required => false
  param :client_profile, String, :desc => 'Client search profile', :required => false
  description <<-END
    On successful invocation, the method returns the HTTP status code `201 Created` with the URL of the client as the HTTP `Location` header.
  END
  error 500, 'Server error while creating client'
  def create
    begin
      client = Client.create!(
          :client_data => params[:client_data],
          :client_profile => params[:client_profile]
      )

      render text: 'Created', location: client_url(client), status: 201
    rescue Mongoid::Errors::MongoidError => e
      render text: "Error creating client: #{e.message}", status: 500
    end
  end

  def update

  end

  def delete

  end
end