class ClientsController < ApplicationController
  resource_description do
    short 'Service Broker Clients'
    full_description <<-END
A broker client represents a company or single person who uses the broker to find and book compliant cloud services.

## XML data format

|---------+------------+--------------+------+-----------|
|Type     |Multiplicity|Name          |Type  |Description|
|---------+------------+--------------+------+-----------|
|Attribute|1           |url           |string|The client URL
|Element  |0..1        |client_profile|string|The client search profile
|Element  |0..1        |client_data   |string|Arbitrary data about the client
|---------+------------+--------------+------+-----------|

## Client search profile

The client search profile is a simple Ruby DSL for specifying criteria for services to match. It consists of any numer of lines conforming to the following format:

`property` `matcher` `value`

These are described in the following

### `property`

The `property` token should correspond to a service property, e.g., `cloud_service_model`, `billing_information`, or `is_protected_by`.

Sub-properties can be appended to the super property using `_`, e.g., `compatible_browsers_browser` or `provider_employs`.

### `matcher`

The `matcher` token defines what kind of query should be executed.

The following matchers exist:

* `should_be` / `should_not_be` (Property value should (not) be exactly)
* `should_include` / `should_not_include` (The property value(s) should (not) include the given values)
* `should_be_at_least` / `should_be_at_most` (A numeric property value should be <= / >= the given value)
* `should_be_defined` / `should_not_be_defined` (A property should (not) be defined)

### `value`

Possible value types include:

* Simple values (e.g., `42`, `"the answer"`, or `true`)
* Arrays of simple values (e.g., `["a", "b", "c"]` or `[1, 2, 3]`)
* References to predefined instances (e.g. `firefox` or `credit_card`)
* Arrays of references to predefined instances (e.g. `[firefox, chrome, internet_explorer]`)

### Examples

`cloud_service_model should_be saas`

`service_tags should_include ["a", "c"]`

`compatible_browsers_browser should_include firefox`

`provider_employs should_be_at_least 1000`

`provider_employs should_be_at_most 1000`

`can_be_used_offline should_be true`

`maintenance_free should_be_defined`
    END
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
  error 500, 'Internal server error while creating or updating client'
  def update
    client_attributes = {}
    client_attributes['client_data'] = params[:client_data] if params[:client_data]
    client_attributes['client_profile'] = params[:client_profile] if params[:client_profile]

    operation_result = Client.collection.find(_id: params[:id]).update({'$set' => client_attributes}, [:upsert])

    if operation_result['updatedExisting']
      head :no_content
    else
      head :created
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

  api :GET, 'client/compatible_services', 'Gets services compatible to the search profile'
  description <<-END
    For details on the format of the client profile, please see the resource description.

    # Example Response
    ~~~ xml
    <?xml version="1.0"?>
    <compatible_services count="3">
      <compatible_service url="http://test.host/services/1HaN6553aL7iM7xJ8ZOP_-untitled"/>
      <compatible_service url="http://test.host/services/2bdimZvf1iJQ4PlX0MvVY-untitled"/>
      <compatible_service url="http://test.host/services/3ZVk30FkuEjxjXhgYtybx-untitled"/>
    </compatible_services>
    ~~~
  END
  error 404, 'The client does not exist'
  error 422, 'The client profile is invalid'
  def compatible_services
    begin
      client = Client.find(params[:id])

      profile = ClientProfile.new(client.client_profile)

      @compatible_services = profile.compatible_services
    rescue ClientProfile::ClientProfileError => e
      render text: "Client profile error: #{e}", status: 422
    rescue Mongoid::Errors::DocumentNotFound
      render text: 'Client not found', status: 404
    end
  end
end