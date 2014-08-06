class ProvidersController < ApplicationController
  resource_description do
    short 'Service Broker Providers'
  end

  respond_to :xml

  api :GET, 'providers', 'Returns a list of all providers known to the broker.'
  formats ['xml']
  description <<-END
    # Example Response
    ~~~ xml
    <?xml version="1.0"?>
    <providers count="3">
      <provider url="http://192.168.147.145:3000/providers/be21c819-6bc7-4c09-b565-0ce72048b25c">
        <provider_data><![CDATA[DATA]]></provider_data>
      </provider>
      <provider url="http://192.168.147.145:3000/providers/08091a55-dd99-4e8f-a11a-0dc7ce7a2d31">
        <provider_data><![CDATA[DATA]]></provider_data>
      </provider>
      <provider url="http://192.168.147.145:3000/providers/ed4c2db1-7642-4caf-88cd-706f05cae2fe">
        <provider_data><![CDATA[DATA]]></provider_data>
      </provider>
    </providers>
    ~~~
  END
  def index
    @providers = Provider.all
  end

  api :GET, 'providers/:id', 'Shows a provider'
  formats ['xml']
  description <<-END
    # Example Response
    ~~~ xml
    <?xml version="1.0"?>
    <provider url="http://192.168.147.145:3000/providers/be21c819-6bc7-4c09-b565-0ce72048b25c">
      <provider_data><![CDATA[DATA]]></provider_data>
    </provider>
    ~~~
  END
  error 404, 'The provider does not exist'
  def show
    begin
      @provider = Provider.find(params[:id])
    rescue Mongoid::Errors::DocumentNotFound
      render text: 'Provider not found', status: 404
    end
  end

  api :POST, 'providers', 'Creates a new provider'
  param :provider_data, String, :desc => 'Arbitrary provider data', :required => false
  description <<-END
    On successful completion, the method returns the HTTP status code `201 Created` with the URL of the provider as the HTTP `Location` header.
  END
  error 500, 'Server error while creating provider'
  def create
    begin
      provider = Provider.create!(
          :provider_data => params[:provider_data]
      )

      head :created, location: provider_url(provider)
    rescue Mongoid::Errors::MongoidError => e
      render text: "Error creating provider: #{e.message}", status: 500
    end
  end

  api :PUT, 'providers/:id', 'Updates or creates a new provider with the specified id'
  param :provider_data, String, :desc => 'Arbitrary provider data', :required => false
  description <<-END
    If the provider does not exist yet, the method creates a new provider and returns `201 Created`.

    If the provider already exists, the method updates `provider_data` and returns `204 No Content`.
  END
  error 500, 'Internal server error while creating or updating provider'
  def update
    provider_attributes = {}
    provider_attributes['provider_data'] = params[:provider_data] if params[:provider_data]

    operation_result = Provider.collection.find(_id: params[:id]).update({'$set' => provider_attributes}, [:upsert])

    if operation_result['updatedExisting']
      head :no_content
    else
      head :created
    end
  end

  api :DELETE, 'provider/:id', 'Deletes a provider'
  description <<-END
    On successful completion, the method returns the HTTP status code `204 No Content`.
  END
  error 404, 'The provider does not exist'
  def destroy
    begin
      Provider.find(params[:id]).destroy

      head :no_content
    rescue Mongoid::Errors::DocumentNotFound
      render text: 'Provider not found', status: 404
    end
  end
end