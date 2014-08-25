require 'spec_helper'
require 'webmock/rspec'

describe BookingsController do
  before(:each) do
    [ServiceBooking, Service, Client].each do |klass|
      klass.with(safe:true).delete_all
    end

    stub_request(:post, 'http://market.place/bookings')
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

  describe 'POST #create' do
    before(:each) do
      ResqueSpec.reset!
      Resque.redis.flushall
    end

    it 'creates a new booking and enques a new resque booking task' do
      client = create(:client)
      service = create(:approved_service)

      post :create, :client_id => client._id, :service_id => service.service_id, :format => :xml

      expect(response).to be_success
      expect(response.status).to eq(201)
      expect(response['Location']).to eq(client_booking_url(client._id, ServiceBooking.first._id))

      expect(BookingWorker).to have_queued('test.host', ServiceBooking.first._id, 'book').in(:booking)
    end

    it 'responds with 404 if the client does not exist' do
      post :create, :client_id => 'abc', :service_id => create(:service).service_id, :callback_url => 'http://test.host', :format => :xml

      expect(response).to be_missing
      expect(response.status).to eq(404)
    end

    it 'responds with 422 if the service does not exist' do
      post :create, :client_id => create(:client)._id, :service_id => 'abc', :callback_url => 'http://test.host', :format => :xml

      expect(response).to be_client_error
      expect(response.status).to eq(422)
    end

    it 'responds with 422 if the callback URL is invalid' do
      post :create, :client_id => create(:client)._id, :service_id => create(:service)._id, :callback_url => 'invalid', :format => :xml

      expect(response).to be_client_error
      expect(response.status).to eq(422)
    end

    it 'responds with 422 if there is no bookable version of a service' do
      service = create(:draft_service)

      post :create, :client_id => create(:client)._id, :service_id => service.service_id, :callback_url => 'http://test.host', :format => :xml

      expect(response).to be_client_error
      expect(response.status).to eq(422)
    end

    it 'can book immediately bookable services' do
      ResqueSpec.inline = true

      service = create(:immediately_bookable_service)
      client = create(:client)

      post :create, :client_id => client._id, :service_id => service.service_id, :format => :xml

      booking = ServiceBooking.first

      expect(booking.booking_status).to eq :booked
      expect(booking.endpoint_url).to eq service.immediate_booking.endpoint_url.value
      expect(booking.booking_time).to be < Time.now
    end
  end

  describe 'DELETE #destroy' do
    before(:each) do
      ResqueSpec.reset!
      Resque.redis.flushall
    end

    it 'returns 204 and enques a new resque cancelation task' do
      booking = create(:booked_service_booking)

      delete :destroy, :client_id => booking.client._id, :id => booking._id, :format => :xml

      expect(response).to be_success
      expect(response.status).to eq(204)

      expect(BookingWorker).to have_queued('test.host', ServiceBooking.first._id, 'cancel').in(:booking)
    end

    it 'can cancel immediately bookable services' do
      ResqueSpec.inline = true

      booking = create(:booked_service_booking)

      delete :destroy, :client_id => booking.client._id, :id => booking._id, :format => :xml

      booking = ServiceBooking.first

      expect(booking.booking_status).to eq :canceled
      expect(booking.canceled_time).to be < Time.now
    end
  end
end