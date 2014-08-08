require 'spec_helper'
require 'webmock/rspec'

describe BookingWorker, :type => :request do
  before(:each) do
    [ServiceBooking, Service, Client].each do |klass|
      klass.with(safe:true).delete_all
    end

    ResqueSpec.reset!
    Resque.redis.flushall
  end

  it 'should notify the callback URL about the booking with the booking as XML content' do
    ResqueSpec.inline = true

    booking = create(:booking_service_booking)
    booking.update!(callback_url: 'http://my.test.host/callback')

    stub_request(:post, "http://my.test.host/callback")

    Resque.enqueue(BookingWorker, '127.0.0.1', booking._id, 'book')

    get(client_booking_url(booking.client, booking), :format => :xml)

    expect(WebMock).to have_requested(:post, 'http://my.test.host/callback').with(
        :body => response.body,
        :headers => {
            'Content-Type' => 'application/xml'
        }
    )
  end

  it 'should notify the callback URL about the cancelation with the booking as XML content' do
    ResqueSpec.inline = true

    booking = create(:booked_service_booking)
    booking.update!(callback_url: 'http://my.test.host/callback')

    stub_request(:post, "http://my.test.host/callback")

    Resque.enqueue(BookingWorker, '127.0.0.1', booking._id, 'cancel')

    get(client_booking_url(booking.client, booking), :format => :xml)

    expect(WebMock).to have_requested(:post, 'http://my.test.host/callback').with(
      :body => response.body,
      :headers => {
        'Content-Type' => 'application/xml'
      }
    )
  end
end