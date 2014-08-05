require 'spec_helper'

describe ClientsController do
  include_context 'with existing clients'

  describe 'GET #index' do
    it "responds with an HTTP 200 status code and the list of clients" do
      get :index, :format => :xml

      expect(response).to be_success
      expect(response.status).to eq(200)

      expect(assigns[:clients]).to have_exactly(3).clients
    end
  end

  describe 'GET #show' do
    it "responds with an HTTP 200 status code and shows a single client" do
      get :show, :id => Client.first._id, :format => :xml

      expect(response).to be_success
      expect(response.status).to eq(200)

      expect(assigns[:client]).to eq Client.first
    end
  end
end