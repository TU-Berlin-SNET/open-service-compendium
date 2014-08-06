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
    On successful completion, the method returns the HTTP status code `201 Created` with the URL of the client as the HTTP `Location` header.
  END
  error 500, 'Server error while creating client'
  def create
    begin
      client = Client.create!(
          :client_data => params[:client_data],
          :client_profile => params[:client_profile]
      )

      head :created, location: client_url(client)
    rescue Mongoid::Errors::MongoidError => e
      render text: "Error creating client: #{e.message}", status: 500
    end
  end

  api :PUT, 'clients/:id', 'Updates or creates a new client with the specified id'
  param :client_data, String, :desc => 'Arbitrary client data', :required => false
  param :client_profile, String, :desc => 'Client search profile', :required => false
  description <<-END
    If the client does not exist yet, the method creates a new client and returns `201 Created`.

    If the client already exists, the method updates `client_data` and `client_profile` if specified and returns `204 No Content`.
  END
  error 422, 'ID missing or invalid'
  error 500, 'Internal server error while creating or updating client'
  def update
    if params[:id]
      client_attributes = {}
      client_attributes['client_data'] = params[:client_data] if params[:client_data]
      client_attributes['client_profile'] = params[:client_profile] if params[:client_profile]

      operation_result = Client.collection.find(_id: params[:id]).update({'$set' => client_attributes}, [:upsert])

      if operation_result['updatedExisting']
        head :no_content
      else
        head :created
      end
    else
      render text: 'ID missing or invalid', status: 422
    end
  end

  api :DELETE, 'client/:id', 'Deletes a client'
  description <<-END
    On successful completion, the method returns the HTTP status code `204 No Content`.
  END
  error 404, 'The client does not exist'
  def destroy
    begin
      Client.find(params[:id]).destroy

      head :no_content
    rescue Mongoid::Errors::DocumentNotFound
      render text: 'Client not found', status: 404
    end
  end
end