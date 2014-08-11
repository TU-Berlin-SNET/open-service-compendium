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
    before(:each) do
      Client.delete_all
      Service.delete_all
    end

    context 'can retrieve a list of compatible services' do
      it 'with "should_be identifier" syntax' do
        client = create(:client, client_profile: 'cloud_service_model should_be saas')

        saas_service = create(:service, sdl_parts: {'main' => 'cloud_service_model saas'})
        paas_service = create(:service, sdl_parts: {'main' => 'cloud_service_model paas'})
        iaas_service = create(:service, sdl_parts: {'main' => 'cloud_service_model iaas'})

        get :compatible_services, :id => client._id, :format => :xml

        expect(response).to be_successful
        expect(response.status).to eq(200)

        compatible_services = assigns(:compatible_services).to_a

        expect(compatible_services).to include saas_service
        expect(compatible_services).not_to include paas_service, iaas_service
      end

      it 'with should_include value syntax' do
        client = create(:client, client_profile: 'service_tags should_include ["a", "c"]')

        abc_service = create(:service, sdl_parts: {'main' => "service_tag 'a'\r\nservice_tag 'b'\r\nservice_tag 'c'"})
        bd_service = create(:service, sdl_parts: {'main' => "service_tag 'b'\r\nservice_tag 'd'"})
        c_service = create(:service, sdl_parts: {'main' => "service_tag 'c'"})

        get :compatible_services, :id => client._id, :format => :xml

        expect(response).to be_successful
        expect(response.status).to eq(200)

        compatible_services = assigns(:compatible_services).to_a

        expect(compatible_services).to include abc_service, c_service
        expect(compatible_services).not_to include bd_service
      end

      it 'with should_include instance syntax' do
        client = create(:client, client_profile: 'compatible_browsers_browser should_include firefox')

        ff_service = create(:service, sdl_parts: {'main' => "compatible_browser firefox"})
        ieff_service = create(:service, sdl_parts: {'main' => "compatible_browser firefox\r\ncompatible_browser internet_explorer"})
        ie_service = create(:service, sdl_parts: {'main' => "compatible_browser internet_explorer"})

        get :compatible_services, :id => client._id, :format => :xml

        expect(response).to be_successful
        expect(response.status).to eq(200)

        compatible_services = assigns(:compatible_services).to_a

        expect(compatible_services).to include ff_service, ieff_service
        expect(compatible_services).not_to include ie_service
      end
    end
  end
end