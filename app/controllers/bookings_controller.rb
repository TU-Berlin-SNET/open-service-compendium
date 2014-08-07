class BookingsController < ApplicationController
  resource_description do
    short 'Service bookings'
    full_description <<-END
A service booking is the result of a user booking a service through the Cloud Marketplace.

## XML data format

|---------+------------+-------------+------+-----------|
|Type     |Multiplicity|Name         |Type  |Description|
|---------+------------+-------------+------+-----------|
|Attribute|1           |url          |string|The booking URL
|Element  |1           |callback_url |string|The callback URL for notifying the Cloud Marketplace about `booking` and `canceled` statuses
|Element  |0..1        |endpoint_url |string|The service endpoint URL specified by the service backend
|Element  |1           |status       |string|The statuses (see [statuses](#statuses))
|Element  |0..1        |failed_reason|string|The failure reason
|Element  |0..1        |*status*_time|date  |The date a specific status has occured (e.g., 'booked_time' or 'canceling_time')
|---------+------------+-------------+------+-----------|

## Statuses

A service booking goes through the following statuses:

### `booking`

The initial status. The Broker notifies the service backend about the booking (e.g. asynchronous calls to a RESTful API). How this is done is specified in the service description.

This notification can either succeed or fail, represented by the `booking_failed` and `booked` statuses.

### `booking_failed`

The booking failed. The field `failed_reason` contains the reason for the failure.

### `booked`

The service was booked successfully and the Cloud Marketplace is notified using the `callback_url`.

### `locked`

Reserved for later use

### `canceling`

The service booking was canceled by the user. The Broker notifies the service backend about the cancelation using information from the service description. The service is still usable, e.g., if the canceling will happen at the end of the month.

### `canceling_failed`

The cancelation failed.

### `canceled`

The service booking was canceled and the Cloud Marketplace is notified using the `callback_url`.

    END
  end

  respond_to :xml

  api :GET, 'clients/:id/bookings', 'Retrieves the service bookings of a client'
  formats ['xml']
  description <<-END
# Example response
~~~ xml
<?xml version="1.0"?>
<bookings count="7">
  <booking
          url="http://test.host/clients/4f3d6824-5846-4e20-81e4-2a98a9cdb1d0/bookings/e3854730-f2e9-413c-9778-921ff7bf80ea">
    <callback_url>http://tresor-dev-mp.snet.tu-berlin.de/booking_completed</callback_url>
    <endpoint_url>http://www.cloud-tresor.de</endpoint_url>
    <status>booking</status>
    <booking_time>2014-08-07T11:08:08Z</booking_time>
  </booking>
  <booking
          url="http://test.host/clients/4f3d6824-5846-4e20-81e4-2a98a9cdb1d0/bookings/1a68fb90-49e1-4129-b983-ae898fd8bca2">
    <callback_url>http://tresor-dev-mp.snet.tu-berlin.de/booking_completed</callback_url>
    <endpoint_url>http://www.cloud-tresor.de</endpoint_url>
    <status>booking_failed</status>
    <failed_reason>Could not reach service backend.</failed_reason>
    <booking_time>2014-08-07T11:08:08Z</booking_time>
    <booking_failed_time>2014-08-07T11:08:08Z</booking_failed_time>
  </booking>
  <booking
          url="http://test.host/clients/4f3d6824-5846-4e20-81e4-2a98a9cdb1d0/bookings/7242c26a-ea91-475e-ba1f-fecb2a38c0c8">
    <callback_url>http://tresor-dev-mp.snet.tu-berlin.de/booking_completed</callback_url>
    <endpoint_url>http://www.cloud-tresor.de</endpoint_url>
    <status>booked</status>
    <booking_time>2014-08-07T11:08:08Z</booking_time>
    <booked_time>2014-08-07T11:08:08Z</booked_time>
  </booking>
  <booking
          url="http://test.host/clients/4f3d6824-5846-4e20-81e4-2a98a9cdb1d0/bookings/deda26ac-0ef3-42fe-a00f-57146550729c">
    <callback_url>http://tresor-dev-mp.snet.tu-berlin.de/booking_completed</callback_url>
    <endpoint_url>http://www.cloud-tresor.de</endpoint_url>
    <status>canceling</status>
    <booking_time>2014-08-07T11:08:08Z</booking_time>
    <booked_time>2014-08-07T11:08:08Z</booked_time>
    <canceling_time>2014-08-07T11:08:08Z</canceling_time>
  </booking>
  <booking
          url="http://test.host/clients/4f3d6824-5846-4e20-81e4-2a98a9cdb1d0/bookings/2207a2da-199d-4aae-bae2-574b761a041d">
    <callback_url>http://tresor-dev-mp.snet.tu-berlin.de/booking_completed</callback_url>
    <endpoint_url>http://www.cloud-tresor.de</endpoint_url>
    <status>canceling_failed</status>
    <failed_reason>Could not reach service backend.</failed_reason>
    <booking_time>2014-08-07T11:08:08Z</booking_time>
    <booked_time>2014-08-07T11:08:08Z</booked_time>
    <canceling_time>2014-08-07T11:08:08Z</canceling_time>
    <canceling_failed_time>2014-08-07T11:08:08Z</canceling_failed_time>
  </booking>
  <booking
          url="http://test.host/clients/4f3d6824-5846-4e20-81e4-2a98a9cdb1d0/bookings/9fa64b14-0e35-4ed4-a29a-7e27177adb25">
    <callback_url>http://tresor-dev-mp.snet.tu-berlin.de/booking_completed</callback_url>
    <endpoint_url>http://www.cloud-tresor.de</endpoint_url>
    <status>canceled</status>
    <booking_time>2014-08-07T11:08:08Z</booking_time>
    <booked_time>2014-08-07T11:08:08Z</booked_time>
    <canceling_time>2014-08-07T11:08:08Z</canceling_time>
    <canceled_time>2014-08-07T11:08:08Z</canceled_time>
  </booking>
  <booking
          url="http://test.host/clients/4f3d6824-5846-4e20-81e4-2a98a9cdb1d0/bookings/3bb3d564-858e-446b-bd8b-aa151ea6ae02">
    <callback_url>http://tresor-dev-mp.snet.tu-berlin.de/booking_completed</callback_url>
    <endpoint_url>http://www.cloud-tresor.de</endpoint_url>
    <status>locked</status>
    <booking_time>2014-08-07T11:08:08Z</booking_time>
    <booked_time>2014-08-07T11:08:08Z</booked_time>
    <locked_time>2014-08-07T11:08:08Z</locked_time>
  </booking>
</bookings>
~~~
  END
  def index
    @bookings = ServiceBooking.where(client_id: params[:client_id])
  end

  api :GET, 'clients/:id/bookings/:id', 'Retrieves a service booking'
  formats ['xml']
  description <<-END
# Example response
~~~ xml
<?xml version="1.0"?>
<booking
        url="http://test.host/clients/4f3d6824-5846-4e20-81e4-2a98a9cdb1d0/bookings/2207a2da-199d-4aae-bae2-574b761a041d">
  <callback_url>http://tresor-dev-mp.snet.tu-berlin.de/booking_completed</callback_url>
  <endpoint_url>http://www.cloud-tresor.de</endpoint_url>
  <status>canceling_failed</status>
  <failed_reason>Could not reach service backend.</failed_reason>
  <booking_time>2014-08-07T11:08:08Z</booking_time>
  <booked_time>2014-08-07T11:08:08Z</booked_time>
  <canceling_time>2014-08-07T11:08:08Z</canceling_time>
  <canceling_failed_time>2014-08-07T11:08:08Z</canceling_failed_time>
</booking>
  END
  error 404, 'The booking does not exist'
  def show
    begin
      @booking = ServiceBooking.where(client_id: params[:client_id]).find(params[:id])
    rescue Mongoid::Errors::DocumentNotFound
      render text: 'Booking not found', status: 404
    end
  end

  api :POST, 'clients/:id/bookings', 'Creates a new service booking'
  formats ['xml']
  description <<-END
    On successful completion, the method returns the HTTP status code `201 Created` with the URL of the booking as the HTTP `Location` header.
  END
  param :service_id, String, :desc => 'The ID of the service which should be booked', :required => true
  param :callback_url, String, :desc => 'The callback URL of the Cloud Marketplace', :required => true
  error 404, 'The client does not exist'
  error 422, 'The service does not exist'
  error 422, 'The callback URL is missing or invalid'
  def create
    if !Client.where(_id: params[:client_id]).exists?
      render text: 'The client does not exist', status: 404
    elsif !Service.where(_id: params[:service_id]).exists?
      #TODO: Test if service is bookable
      render text: 'The service does not exist', status: 422
    elsif (params[:callback_url].blank?)
      render text: 'The callback URL is missing', status: 422
    else
      begin
        callback_uri = URI.parse(params[:callback_url])

        raise URI::InvalidURIError unless %w[http https].include? callback_uri.scheme

        booking = ServiceBooking.create(
            client_id: params[:client_id],
            service_id: params[:service_id],
            booking_time: Time.new,
            callback_url: params[:callback_url])

        Resque.enqueue(BookingWorker, booking._id, :book)

        head :created, location: client_booking_url(params[:client_id], booking._id)
      rescue URI::InvalidURIError
        render text: 'The callback URL is invalid', status: 422
      rescue Exception => e
        render text: e.message, status: 500
      end
    end
  end
end