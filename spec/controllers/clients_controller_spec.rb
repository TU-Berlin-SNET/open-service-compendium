require 'spec_helper'

describe ClientsController do
  before(:each) do
    Client.delete_all
  end

  describe 'GET #index' do
    include_context 'with existing clients'

    it "responds with an HTTP 200 status code and the list of clients" do
      get :index, :format => :xml

      expect(response).to be_success
      expect(response.status).to eq(200)

      expect(assigns[:clients]).to have_exactly(3).clients
    end
  end

  describe 'GET #show' do
    include_context 'with existing clients'

    it 'responds with an HTTP 200 status code and shows a single client' do
      get :show, :id => Client.first._id, :format => :xml

      expect(response).to be_success
      expect(response.status).to eq(200)

      expect(assigns[:client]).to eq Client.first
    end

    it 'returns a 404 error if the client cannot be found' do
      get :show, :id => 'ABC123', :format => :xml

      expect(response).to be_missing
      expect(response.status).to eq(404)
    end
  end

  describe 'POST #create' do
    it 'responds with 201 and returns the correct client URL' do
      post :create, :client_data => 'client data', :client_profile => 'client profile'

      expect(response).to be_success
      expect(response.status).to eq(201)
      expect(response['Location']).to eq(client_url(Client.first))
    end
  end

  describe 'PUT #update' do
    it 'creates a new client and responds with 201 if the client did not exist' do
      put :update, :id => 'new-id', :client_data => 'client data', :client_profile => 'client profile'

      expect(Client.find('new-id').client_data).to eq 'client data'

      expect(response).to be_success
      expect(response.status).to eq 201
    end

    it 'updates an existing client and responds with 204' do
      client = Client.create(:client_data => 'old', :client_profile => 'old')

      put :update, :id => client._id, :client_data => 'new'

      client.reload

      expect(response).to be_success
      expect(response.status).to eq 204

      expect(client.client_data).to eq 'new'
      expect(client.client_profile).to eq 'old'
    end

    it 'responds with 422 if specifying invalid or missing parameters' do
      client = Client.create(:client_data => 'old', :client_profile => 'old')

      put :update, :id => client._id, :invalid => 'abc'

      expect(response).to be_client_error
      expect(response.status).to eq 422

      put :update, :id => client._id

      client.reload

      expect(response).to be_client_error
      expect(response.status).to eq 422

      client.reload

      expect(client.client_data).to eq 'old'
      expect(client.client_profile).to eq 'old'
    end
  end

  describe 'DELETE #delete' do
    it 'deletes a client and returns 204' do
      client = Client.create

      delete :destroy, id: client._id

      expect(response).to be_success
      expect(response.status).to eq(204)

      expect {Client.find(client._id)}.to raise_exception Mongoid::Errors::DocumentNotFound
    end

    it 'returns a 404 error if the client cannot be found' do
      delete :destroy, id: 'ABC'

      expect(response).to be_missing
      expect(response.status).to eq(404)
    end
  end

  context 'a client profile' do
    context 'can retrieve a list of compatible services' do
      include_context 'with client profile examples'

      client_profile_examples.each do |syntax, data|
        it "with supports '#{syntax}' syntax syntax" do
          client = create(:client, client_profile: data[:profile])

          created_services = {}

          data[:services].each do |identifier, sdl|
            created_services[identifier] = create(:service, sdl_parts: {'meta' => 'status approved', 'main' => sdl})
          end

          get :compatible_services, :id => client._id, :format => :xml

          expect(response).to be_successful
          expect(response.status).to eq(200)

          compatible_services = assigns(:compatible_services).to_a

          included_services = created_services.select{|k, v| data[:included].include? k}.values
          not_included_services = (created_services.values - included_services)

          expect(compatible_services.to_a).to include *included_services
          expect(compatible_services.to_a).not_to include *not_included_services
        end
      end
    end
  end
end