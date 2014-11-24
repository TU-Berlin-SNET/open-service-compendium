class BookingsController < ApplicationController
  resource_description do
    short 'Service bookings'
    full_description <<-END
A service booking is the result of a user booking the latest approved, non-deleted version of a service through the Cloud Marketplace.

## XML data format

|---------+------------+-------------+------+-----------|
|Type     |Multiplicity|Name         |Type  |Description|
|---------+------------+-------------+------+-----------|
|Attribute|1           |url          |string|The booking URL
|Element  |1           |client_url   |string|The URL of the client who initiated the booking
|Element  |1           |service_url  |string|The URL of the specific service version, which was the latest approved, non-deleted version at the moment of booking
|Element  |0..1        |callback_url |string|The callback URL for notifying the Cloud Marketplace about `booking` and `canceled` statuses
|Element  |0..1        |endpoint_url |string|The service endpoint URL specified by the service backend
|Element  |1           |status       |string|The statuses (see [statuses](#statuses))
|Element  |0..1        |failed_reason|string|The failure reason
|Element  |0..1        |*status*_time|date  |The date a specific status has occured (e.g., 'booked_time' or 'canceling_time')
|---------+------------+-------------+------+-----------|

## Booking, Provisioning and Deployment process

After creating bookings or deleting a booking, the Broker starts a background worker which informs the service backend about the action, based on information in the service description.

Additionally, the broker starts another background worker, which informs the policy management system about the access policy which should be applied to client user accounts accessing the service.

The service backend should then provision or deprovision a service instance for the user and, if first provisioning, return an endpoint URL to the broker, which is used by the Proxy to route service requests.

After the worker completes, the callback URL receives the result of the action as a POST request, as it would have been rendered by GET /clients/:id/bookings/:id.

There are two different booking types:

### Immediate booking

The immediate booking is simple: the endpoint URL given in the service description is used as the endpoint URL of the booking.

### Synchronous booking

Not implemented yet

## Service access policies

When booking a service, there are three possible access policies, which the broker can upload to the access management system. A client can additionally use the Policy Administration Point (PAP) for flexible adjustment of these access policies.

### `deny_all`

The policy denies all client user accounts access to the service.

### `allow_all`

The policy allows all client user accounts access to the service.

### `allow_from_usergroup`

The policy allows only those client user accounts belonging to a specific user group access to the service.

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

  respond_to :xml, :html

  api :GET, 'clients/:id/bookings', 'Retrieves the service bookings of a client'
  formats ['xml']
  description <<-END
# Example response
~~~ xml
<?xml version="1.0"?>
<bookings count="7">
  <booking
          url="http://test.host/clients/3115a7c2-2cc1-436e-b35f-67da5d3b84f4/bookings/7e395ce0-d17f-460b-adbc-ca038cae5dba">
    <client_url>http://test.host/clients/3115a7c2-2cc1-436e-b35f-67da5d3b84f4</client_url>
    <service_url>
      http://test.host/services/8c3e499c-d3b7-4f87-86e3-aa2ee896d50d/versions/b1e39522-57a9-4776-b34f-95ebfc57a3a3
    </service_url>
    <callback_url>http://market.place/bookings</callback_url>
    <endpoint_url>http://www.cloud-tresor.de</endpoint_url>
    <status>booking</status>
    <booking_time>2014-08-21T08:38:36Z</booking_time>
  </booking>
  <booking
          url="http://test.host/clients/3115a7c2-2cc1-436e-b35f-67da5d3b84f4/bookings/13c45ae6-645d-4a92-8949-539624c73fe8">
    <client_url>http://test.host/clients/3115a7c2-2cc1-436e-b35f-67da5d3b84f4</client_url>
    <service_url>
      http://test.host/services/053e1bcf-21c2-4d0d-8980-f5aab30cc853/versions/f272b659-6f05-4a04-a433-23a8b36f6690
    </service_url>
    <callback_url>http://market.place/bookings</callback_url>
    <endpoint_url>http://www.cloud-tresor.de</endpoint_url>
    <status>booking_failed</status>
    <failed_reason>Could not reach service backend.</failed_reason>
    <booking_time>2014-08-21T08:38:36Z</booking_time>
    <booking_failed_time>2014-08-21T08:38:36Z</booking_failed_time>
  </booking>
  <booking
          url="http://test.host/clients/3115a7c2-2cc1-436e-b35f-67da5d3b84f4/bookings/c43ccbd8-60e8-4ad4-bf0f-aeea6f9625c3">
    <client_url>http://test.host/clients/3115a7c2-2cc1-436e-b35f-67da5d3b84f4</client_url>
    <service_url>
      http://test.host/services/0f788e81-1ccd-4329-a22b-773da88cbda7/versions/6eb2758a-f8c7-4b8b-8efc-ab609fdb27a9
    </service_url>
    <callback_url>http://market.place/bookings</callback_url>
    <endpoint_url>http://www.cloud-tresor.de</endpoint_url>
    <status>booked</status>
    <booking_time>2014-08-21T08:38:36Z</booking_time>
    <booked_time>2014-08-21T08:38:36Z</booked_time>
  </booking>
  <booking
          url="http://test.host/clients/3115a7c2-2cc1-436e-b35f-67da5d3b84f4/bookings/6932cf03-7f56-4b9c-b960-c32169f57220">
    <client_url>http://test.host/clients/3115a7c2-2cc1-436e-b35f-67da5d3b84f4</client_url>
    <service_url>
      http://test.host/services/4ebb0b0c-c13d-408f-8a2b-ddd2ffcd08ae/versions/3b48cc01-67da-4b25-b87e-bd6515c7a391
    </service_url>
    <callback_url>http://market.place/bookings</callback_url>
    <endpoint_url>http://www.cloud-tresor.de</endpoint_url>
    <status>canceling</status>
    <booking_time>2014-08-21T08:38:36Z</booking_time>
    <booked_time>2014-08-21T08:38:36Z</booked_time>
    <canceling_time>2014-08-21T08:38:36Z</canceling_time>
  </booking>
  <booking
          url="http://test.host/clients/3115a7c2-2cc1-436e-b35f-67da5d3b84f4/bookings/851f96c8-0a5c-402f-837d-344eb0a964d4">
    <client_url>http://test.host/clients/3115a7c2-2cc1-436e-b35f-67da5d3b84f4</client_url>
    <service_url>
      http://test.host/services/9ddb35f3-f274-4bc0-b4a1-bcad38a69b74/versions/5544c59d-6ed7-4871-bb6f-67b7093085a6
    </service_url>
    <callback_url>http://market.place/bookings</callback_url>
    <endpoint_url>http://www.cloud-tresor.de</endpoint_url>
    <status>canceling_failed</status>
    <failed_reason>Could not reach service backend.</failed_reason>
    <booking_time>2014-08-21T08:38:37Z</booking_time>
    <booked_time>2014-08-21T08:38:37Z</booked_time>
    <canceling_time>2014-08-21T08:38:37Z</canceling_time>
    <canceling_failed_time>2014-08-21T08:38:37Z</canceling_failed_time>
  </booking>
  <booking
          url="http://test.host/clients/3115a7c2-2cc1-436e-b35f-67da5d3b84f4/bookings/0159dc5b-a52f-4afe-9b12-6054bc0f2dda">
    <client_url>http://test.host/clients/3115a7c2-2cc1-436e-b35f-67da5d3b84f4</client_url>
    <service_url>
      http://test.host/services/137a18d4-b78c-4bf5-a557-4525b5581672/versions/5c53c039-4b55-48be-94b7-08de1ac70e55
    </service_url>
    <callback_url>http://market.place/bookings</callback_url>
    <endpoint_url>http://www.cloud-tresor.de</endpoint_url>
    <status>canceled</status>
    <booking_time>2014-08-21T08:38:37Z</booking_time>
    <booked_time>2014-08-21T08:38:37Z</booked_time>
    <canceling_time>2014-08-21T08:38:37Z</canceling_time>
    <canceled_time>2014-08-21T08:38:37Z</canceled_time>
  </booking>
  <booking
          url="http://test.host/clients/3115a7c2-2cc1-436e-b35f-67da5d3b84f4/bookings/b9839416-1689-43f2-9f5e-50108556ecf4">
    <client_url>http://test.host/clients/3115a7c2-2cc1-436e-b35f-67da5d3b84f4</client_url>
    <service_url>
      http://test.host/services/ad7d83e8-02ae-41b4-82d1-ba9083aa17a0/versions/b6040158-d7fd-4723-8f6c-138e04b68e2e
    </service_url>
    <callback_url>http://market.place/bookings</callback_url>
    <endpoint_url>http://www.cloud-tresor.de</endpoint_url>
    <status>locked</status>
    <booking_time>2014-08-21T08:38:37Z</booking_time>
    <booked_time>2014-08-21T08:38:37Z</booked_time>
    <locked_time>2014-08-21T08:38:37Z</locked_time>
  </booking>
</bookings>
~~~
  END
  def index
    @bookings = ServiceBooking.where(client_id: params[:client_id], booking_status: {'$ne' => :canceled})
  end

  api :GET, 'bookings', 'Retrieves all service bookings'
  formats ['xml']
  def list_all
    @bookings = ServiceBooking.where(booking_status: {'$ne' => :canceled})

    render 'bookings/index'
  end

  api :GET, 'clients/:id/bookings/:id', 'Retrieves a service booking'
  formats ['xml']
  description <<-END
# Example response
~~~ xml
<?xml version="1.0"?>
<booking
        url="http://test.host/clients/826934e7-f192-42d3-88b6-8656c6132703/bookings/9591a380-45f7-4eea-b129-b263a1aa642c">
  <client_url>http://test.host/clients/826934e7-f192-42d3-88b6-8656c6132703</client_url>
  <service_url>
    http://test.host/services/2f297cc5-0194-43cd-ac62-10af4eeee0f2/versions/e497593c-4aeb-4acf-abc1-5a47490abbbd
  </service_url>
  <callback_url>http://market.place/bookings</callback_url>
  <endpoint_url>http://www.cloud-tresor.de</endpoint_url>
  <status>canceling_failed</status>
  <failed_reason>Could not reach service backend.</failed_reason>
  <booking_time>2014-08-21T08:40:51Z</booking_time>
  <booked_time>2014-08-21T08:40:51Z</booked_time>
  <canceling_time>2014-08-21T08:40:51Z</canceling_time>
  <canceling_failed_time>2014-08-21T08:40:51Z</canceling_failed_time>
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
This method will create a booking of the latest, approved, non-deleted version of the given service.

On successful completion, the method returns the HTTP status code `201 Created` with the URL of the booking as the HTTP `Location` header. Afterwards, the method starts the booking, provisioning and deployment process (please see [the resource description](#booking-provisioning-and-deployment-process)).
  END
  param :service_id, String, :desc => 'The ID of the service which should be booked', :required => true
  param :callback_url, String, :desc => 'The callback URL of the Cloud Marketplace'
  param :access_policy, %w(deny_all allow_all allow_from_usergroup), :desc => 'The access policy. Defaults to `allow_all`.'
  param :access_policy_usergroup, String, :desc => 'If `access_policy` is `allow_from_usergroup`, define the user group to allow access from.'
  error 404, 'The client does not exist'
  error 422, 'The service does not exist or is not bookable'
  error 422, 'The callback URL is invalid'
  def create
    if !Client.where(_id: params[:client_id]).exists?
      render text: 'The client does not exist', status: 404
    elsif params[:access_policy].present? && %w(deny_all allow_all allow_from_usergroup).exclude?(params[:access_policy])
      render text: 'The access policy is invalid', status: 422
    elsif params[:access_policy] == 'allow_from_usergroup' && params[:access_policy_usergroup].blank?
      render text: 'Please specify access_policy_usergroup parameter for allow_from_usergroup access policy', status: 422
    else
      bookable_service_version = Service.latest_approved(params[:service_id])

      if bookable_service_version.blank?
        render text: 'The service does not exist or is not bookable', status: 422
      else
        begin
          if params[:callback_url]
            callback_uri = URI.parse(params[:callback_url])

            raise URI::InvalidURIError unless %w[http https].include? callback_uri.scheme
          end

          booking = ServiceBooking.create(
              client_id: params[:client_id],
              service_id: bookable_service_version._id,
              booking_time: Time.new,
              callback_url: params[:callback_url])

          Resque.enqueue(BookingWorker, request.host, booking._id, 'book')

          Resque.enqueue(PolicyUploadWorker, params[:access_policy] || 'allow_all', params[:service_id], params[:client_id], params[:access_policy_usergroup])

          respond_to do |format|
            format.html do
              flash[:message] = t('broker.bookings.created')
              redirect_to :back
            end

            format.any do
              head :created, location: client_booking_url(params[:client_id], booking._id)
            end
          end
        rescue URI::InvalidURIError
          render text: 'The callback URL is invalid', status: 422
        rescue Exception => e
          render text: e.message, status: 500
        end
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

        respond_to do |format|
          format.html do
            flash[:message] = t('broker.bookings.deleted')
            redirect_to :back
          end

          format.any do
            head :no_content
          end
        end
      else
        render :text => "The booking cannot be canceled, as its status is '#{booking.booking_status}' instead of 'booked'.", :status => 422
      end
    rescue Mongoid::Errors::DocumentNotFound
      render text: 'Client not found', status: 404
    end
  end

  api :GET, 'services/:id/bookings', 'Retrieves all Bookings for a specific service'
  def for_service
    service_version_ids = Service.where(service_id: params[:id]).only(:_id).map &:_id

    @bookings = ServiceBooking.where(:service_id => {'$in' => service_version_ids}, :booking_status => {'$ne' => :canceled})

    render 'bookings/index'
  end
end