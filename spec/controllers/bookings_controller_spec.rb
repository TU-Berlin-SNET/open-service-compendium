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
      ServiceBooking.with(safe: true).delete_all

      client = create(:client, :with_bookings)

      get :index, :client_id => client._id, :format => :xml

      expect(response).to be_success
      expect(response.status).to eq(200)

      expect(assigns[:bookings]).to have_exactly(6).bookings
    end
  end

  describe 'GET #list_all' do
    it 'responds with an HTTP 200 status code and lists all active bookings' do
      ServiceBooking.with(safe: true).delete_all

      client_a = create(:client, :with_bookings)
      client_b = create(:client, :with_bookings)

      get :list_all, :format => :xml

      expect(response).to be_success
      expect(response.status).to eq(200)

      expect(assigns[:bookings]).to have_exactly(12).bookings
    end
  end

  describe 'GET #for_service' do
    it 'responds with an HTTP 200 status code and lists all active bookings for a service' do
      booking_a = create(:booked_service_booking)
      booking_b = create(:booked_service_booking, :service => booking_a.service)

      get :for_service, :id => booking_a.service.service_id, :format => :xml

      expect(response).to be_success
      expect(response.status).to eq(200)

      expect(assigns[:bookings]).to have_exactly(2).bookings
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

    context 'after creating a new booking' do
      let :client do
        create(:client)
      end

      let :service do
        create(:approved_service)
      end

      before(:each) do
        post :create, :client_id => client._id, :service_id => service.service_id, :format => :xml
      end

      it 'creates a new booking' do
        expect(response).to be_success
        expect(response.status).to eq(201)
        expect(response['Location']).to eq(client_booking_url(client._id, ServiceBooking.first._id))
      end

      it 'enqueues a new booking worker' do
        expect(BookingWorker).to have_queued('test.host', ServiceBooking.first._id, 'book').in(:booking)
      end

      it 'enqueues a new policy upload worker with a default policy of allow_all' do
        expect(PolicyUploadWorker).to have_queued('allow_all', service.service_id, client._id, nil)
      end
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

    it 'responds with 422 if the access_policy is invalid' do
      client = create(:client)
      service = create(:approved_service)

      post :create, :client_id => client._id, :service_id => service.service_id, :access_policy => 'unknown_policy', :format => :xml

      expect(response).to be_client_error
      expect(response.status).to eq(422)
    end

    it 'responds with 422 if the access_policy_usergroup is missing when access_policy is allow_from_usergroup' do
      client = create(:client)
      service = create(:approved_service)

      post :create, :client_id => client._id, :service_id => service.service_id, :access_policy => 'allow_from_usergroup', :format => :xml

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