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
|Element  |1           |client_url   |string|The URL of the client who initiated the booking
|Element  |1           |service_url  |string|The URL of the service
|Element  |0..1        |callback_url |string|The callback URL for notifying the Cloud Marketplace about `booking` and `canceled` statuses
|Element  |0..1        |endpoint_url |string|The service endpoint URL specified by the service backend
|Element  |1           |status       |string|The statuses (see [statuses](#statuses))
|Element  |0..1        |failed_reason|string|The failure reason
|Element  |0..1        |*status*_time|date  |The date a specific status has occured (e.g., 'booked_time' or 'canceling_time')
|---------+------------+-------------+------+-----------|

## Booking, Provisioning and Deployment process

After creating bookings or deleting a booking, the Broker starts a background worker which informs the service backend about the action, based on information in the service description.

The service backend should then provision or deprovision a service instance for the user and, if first provisioning, return an endpoint URL to the broker, which is used by the Proxy to route service requests.

After the worker completes, the callback URL receives the result of the action as a POST request, as it would have been rendered by GET /clients/:id/bookings/:id.

There are two different booking types:

### Immediate booking

The immediate booking is simple: the endpoint URL given in the service description is used as the endpoint URL of the booking.

### Synchronous booking

Not implemented yet

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
          url="http://test.host/clients/cb8931f0-e527-485a-88bd-7d52eeaaf80a/bookings/fabbb152-06ac-436d-adc0-6565f6de7a2e">
    <client_url>http://test.host/clients/cb8931f0-e527-485a-88bd-7d52eeaaf80a</client_url>
    <service_url>http://test.host/services/4a2Z927U4hUP33BpWwgSc</service_url>
    <callback_url>http://tresor-dev-mp.snet.tu-berlin.de/booking_completed</callback_url>
    <endpoint_url>http://www.cloud-tresor.de</endpoint_url>
    <status>booking</status>
    <booking_time>2014-08-07T21:06:32Z</booking_time>
  </booking>
  <booking
          url="http://test.host/clients/cb8931f0-e527-485a-88bd-7d52eeaaf80a/bookings/98c943ad-51bb-4ce8-b0ba-a7f7a1a143b7">
    <client_url>http://test.host/clients/cb8931f0-e527-485a-88bd-7d52eeaaf80a</client_url>
    <service_url>http://test.host/services/2Td2I8pm8g9lcSX5rrQf5</service_url>
    <callback_url>http://tresor-dev-mp.snet.tu-berlin.de/booking_completed</callback_url>
    <endpoint_url>http://www.cloud-tresor.de</endpoint_url>
    <status>booking_failed</status>
    <failed_reason>Could not reach service backend.</failed_reason>
    <booking_time>2014-08-07T21:06:32Z</booking_time>
    <booking_failed_time>2014-08-07T21:06:32Z</booking_failed_time>
  </booking>
  <booking
          url="http://test.host/clients/cb8931f0-e527-485a-88bd-7d52eeaaf80a/bookings/4d5dc4dc-86e8-4830-973a-79d38079fb7c">
    <client_url>http://test.host/clients/cb8931f0-e527-485a-88bd-7d52eeaaf80a</client_url>
    <service_url>http://test.host/services/4vW71H0n0DXLQKME9xldg</service_url>
    <callback_url>http://tresor-dev-mp.snet.tu-berlin.de/booking_completed</callback_url>
    <endpoint_url>http://www.cloud-tresor.de</endpoint_url>
    <status>booked</status>
    <booking_time>2014-08-07T21:06:32Z</booking_time>
    <booked_time>2014-08-07T21:06:32Z</booked_time>
  </booking>
  <booking
          url="http://test.host/clients/cb8931f0-e527-485a-88bd-7d52eeaaf80a/bookings/dbefd37e-815e-48c0-982b-cc9d76b8386c">
    <client_url>http://test.host/clients/cb8931f0-e527-485a-88bd-7d52eeaaf80a</client_url>
    <service_url>http://test.host/services/DUDXzluC_Qat3aMqDFAe</service_url>
    <callback_url>http://tresor-dev-mp.snet.tu-berlin.de/booking_completed</callback_url>
    <endpoint_url>http://www.cloud-tresor.de</endpoint_url>
    <status>canceling</status>
    <booking_time>2014-08-07T21:06:32Z</booking_time>
    <booked_time>2014-08-07T21:06:32Z</booked_time>
    <canceling_time>2014-08-07T21:06:32Z</canceling_time>
  </booking>
  <booking
          url="http://test.host/clients/cb8931f0-e527-485a-88bd-7d52eeaaf80a/bookings/967b4476-79bb-49fa-879d-9d938ab073b8">
    <client_url>http://test.host/clients/cb8931f0-e527-485a-88bd-7d52eeaaf80a</client_url>
    <service_url>http://test.host/services/282Rl4qweXMGVPoOm0_0l</service_url>
    <callback_url>http://tresor-dev-mp.snet.tu-berlin.de/booking_completed</callback_url>
    <endpoint_url>http://www.cloud-tresor.de</endpoint_url>
    <status>canceling_failed</status>
    <failed_reason>Could not reach service backend.</failed_reason>
    <booking_time>2014-08-07T21:06:32Z</booking_time>
    <booked_time>2014-08-07T21:06:32Z</booked_time>
    <canceling_time>2014-08-07T21:06:32Z</canceling_time>
    <canceling_failed_time>2014-08-07T21:06:32Z</canceling_failed_time>
  </booking>
  <booking
          url="http://test.host/clients/cb8931f0-e527-485a-88bd-7d52eeaaf80a/bookings/1915ecd4-ae0f-43ab-b4d4-a01b83164838">
    <client_url>http://test.host/clients/cb8931f0-e527-485a-88bd-7d52eeaaf80a</client_url>
    <service_url>http://test.host/services/3eo764767K87pSeo5v6Rn</service_url>
    <callback_url>http://tresor-dev-mp.snet.tu-berlin.de/booking_completed</callback_url>
    <endpoint_url>http://www.cloud-tresor.de</endpoint_url>
    <status>canceled</status>
    <booking_time>2014-08-07T21:06:32Z</booking_time>
    <booked_time>2014-08-07T21:06:32Z</booked_time>
    <canceling_time>2014-08-07T21:06:32Z</canceling_time>
    <canceled_time>2014-08-07T21:06:32Z</canceled_time>
  </booking>
  <booking
          url="http://test.host/clients/cb8931f0-e527-485a-88bd-7d52eeaaf80a/bookings/221abbd4-5711-4a09-8b34-5971f32ec903">
    <client_url>http://test.host/clients/cb8931f0-e527-485a-88bd-7d52eeaaf80a</client_url>
    <service_url>http://test.host/services/30eWnLpPGmaUlJRpKaqjf</service_url>
    <callback_url>http://tresor-dev-mp.snet.tu-berlin.de/booking_completed</callback_url>
    <endpoint_url>http://www.cloud-tresor.de</endpoint_url>
    <status>locked</status>
    <booking_time>2014-08-07T21:06:32Z</booking_time>
    <booked_time>2014-08-07T21:06:32Z</booked_time>
    <locked_time>2014-08-07T21:06:32Z</locked_time>
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
        url="http://test.host/clients/cb8931f0-e527-485a-88bd-7d52eeaaf80a/bookings/4d5dc4dc-86e8-4830-973a-79d38079fb7c">
  <client_url>http://test.host/clients/cb8931f0-e527-485a-88bd-7d52eeaaf80a</client_url>
  <service_url>http://test.host/services/4vW71H0n0DXLQKME9xldg</service_url>
  <callback_url>http://tresor-dev-mp.snet.tu-berlin.de/booking_completed</callback_url>
  <endpoint_url>http://www.cloud-tresor.de</endpoint_url>
  <status>booked</status>
  <booking_time>2014-08-07T21:06:32Z</booking_time>
  <booked_time>2014-08-07T21:06:32Z</booked_time>
</booking>
~~~
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
On successful completion, the method returns the HTTP status code `201 Created` with the URL of the booking as the HTTP `Location` header. Afterwards, the method starts the booking, provisioning and deployment process (please see [the resource description](#booking-provisioning-and-deployment-process)).
  END
  param :service_id, String, :desc => 'The ID of the service which should be booked', :required => true
  param :callback_url, String, :desc => 'The callback URL of the Cloud Marketplace'
  error 404, 'The client does not exist'
  error 422, 'The service does not exist'
  error 422, 'The callback URL is invalid'
  def create
    if !Client.where(_id: params[:client_id]).exists?
      render text: 'The client does not exist', status: 404
    elsif !Service.where(_id: params[:service_id]).exists?
      #TODO: Test if service is bookable
      render text: 'The service does not exist', status: 422
    else
      begin
        if params[:callback_url]
          callback_uri = URI.parse(params[:callback_url])

          raise URI::InvalidURIError unless %w[http https].include? callback_uri.scheme
        end

        booking = ServiceBooking.create(
            client_id: params[:client_id],
            service_id: params[:service_id],
            booking_time: Time.new,
            callback_url: params[:callback_url])

        Resque.enqueue(BookingWorker, request.host, booking._id, 'book')

        head :created, location: client_booking_url(params[:client_id], booking._id)
      rescue URI::InvalidURIError
        render text: 'The callback URL is invalid', status: 422
      rescue Exception => e
        render text: e.message, status: 500
      end
    end
  end

  api :DELETE, 'clients/:id/bookings/:id', 'Cancel an existing booking'
  description <<-END
On successful completion, the method returns the HTTP status code `204 No Content`. Afterwards, the method starts the cancelation process (please see [the resource description](#booking-provisioning-and-deployment-process)).
  END
  error 404, 'The booking does not exist'
  error 422, 'The booking cannot be canceled'
  def destroy
    begin
      booking = ServiceBooking.find(params[:id])

      if booking.booked?
        Resque.enqueue(BookingWorker, request.host, booking._id, 'cancel')

        head :no_content
      else
        render :text => "The booking cannot be canceled, as its status is '#{booking.booking_status}' instead of 'booked'.", :status => 422
      end
    rescue Mongoid::Errors::DocumentNotFound
      render text: 'Client not found', status: 404
    end
  end
end