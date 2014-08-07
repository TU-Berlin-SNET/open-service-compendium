require 'spec_helper'

describe BookingsController do
  after(:each) do
    [ServiceBooking, Service, Client].each do |klass|
      klass.with(safe:true).delete_all
    end
  end

  describe 'GET #index' do
    it 'responds with an HTTP 200 status code and lists the active bookings' do
      client = create(:client, :with_bookings)

      get :index, :client_id => client._id, :format => :xml

      expect(response).to be_success
      expect(response.status).to eq(200)

      expect(assigns[:bookings]).to have_exactly(ServiceBooking::STATUSES.count).bookings
    end
  end

  describe 'GET #show' do
    it 'responds with an HTTP 200 status code and shows a single booking' do
      booking = create(:booked_service_booking)

      get :show, :id => booking._id, :client_id => booking.client_id, :format => :xml

      expect(response).to be_success
      expect(response.status).to eq(200)

      expect(assigns[:booking]).to eq booking
    end

    it 'returns a 404 error if the booking cannot be found' do
      get :show, :id => 'ABC123', :client_id => 'DEF456', :format => :xml

      expect(response).to be_missing
      expect(response.status).to eq(404)
    end

    it 'does not show a booking, which does not belong to the client' do
      booking = create(:booked_service_booking)

      get :show, :id => booking._id, :client_id => 'any-client', :format => :xml

      expect(response).to be_missing
      expect(response.status).to eq(404)
    end
  end
end