require 'spec_helper'

describe ProvidersController do

  describe 'GET #index' do
    include_context 'with existing providers'

    it "responds with an HTTP 200 status code and the list of providers" do
      get :index, :format => :xml

      expect(response).to be_success
      expect(response.status).to eq(200)

      expect(assigns[:providers]).to have_exactly(3).providers
    end
  end

  describe 'GET #show' do
    include_context 'with existing providers'

    it 'responds with an HTTP 200 status code and shows a single provider' do
      get :show, :id => Provider.first._id, :format => :xml

      expect(response).to be_success
      expect(response.status).to eq(200)

      expect(assigns[:provider]).to eq Provider.first
    end

    it 'returns a 404 error if the provider cannot be found' do
      get :show, :id => 'ABC123', :format => :xml

      expect(response).to be_missing
      expect(response.status).to eq(404)
    end
  end

  describe 'POST #create' do
    after(:each) do
      Provider.delete_all
    end

    it 'responds with 201 and returns the correct provider URL' do
      post :create, :provider_data => 'provider data'

      expect(response).to be_success
      expect(response.status).to eq(201)
      expect(response['Location']).to eq(provider_url(Provider.first))
    end
  end

  describe 'PUT #update' do
    after(:each) do
      Provider.delete_all
    end

    it 'creates a new provider and responds with 201 if the provider did not exist' do
      put :update, :id => 'new-id', :provider_data => 'provider data'

      expect(Provider.find('new-id').provider_data).to eq 'provider data'

      expect(response).to be_success
      expect(response.status).to eq 201
    end

    it 'updates an existing provider and responds with 204' do
      provider = Provider.create(:provider_data => 'old')

      put :update, :id => provider._id, :provider_data => 'new'

      provider.reload

      expect(response).to be_success
      expect(response.status).to eq 204

      expect(provider.provider_data).to eq 'new'
    end

    it 'responds with 422 if specifying invalid or missing parameters' do
      provider = Provider.create(:provider_data => 'old')

      put :update, :id => provider._id, :invalid => 'abc'

      expect(response).to be_client_error
      expect(response.status).to eq 422

      put :update, :id => provider._id

      provider.reload

      expect(response).to be_client_error
      expect(response.status).to eq 422

      provider.reload

      expect(provider.provider_data).to eq 'old'
    end
  end

  describe 'DELETE #delete' do
    after(:each) do
      # If the test fails, leave a clean database
      Provider.delete_all
    end

    it 'deletes a provider and returns 204' do
      provider = Provider.create

      delete :destroy, id: provider._id

      expect(response).to be_success
      expect(response.status).to eq(204)

      expect {Provider.find(provider._id)}.to raise_exception Mongoid::Errors::DocumentNotFound
    end

    it 'returns a 404 error if the provider cannot be found' do
      delete :destroy, id: 'ABC'

      expect(response).to be_missing
      expect(response.status).to eq(404)
    end
  end
end