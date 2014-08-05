require 'spec_helper'

describe ClientsController do
  before :each do
    3.times { create(:client) }
  end

  after :each do
    Client.delete_all
  end

  describe 'GET #index' do
    it "responds with an HTTP 200 status code and the list of clients" do
      get :index, :format => :xml

      expect(response).to be_success
      expect(response.status).to eq(200)

      expect(assigns[:clients]).to have_exactly(3).clients
    end
  end
end