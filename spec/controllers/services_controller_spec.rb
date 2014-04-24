require 'spec_helper'

describe ServicesController do
  describe 'GET /services' do
    it "responds successfully with an HTTP 200 status code" do
      get :list

      expect(response).to be_success
      expect(response.status).to eq(200)
    end
  end
end