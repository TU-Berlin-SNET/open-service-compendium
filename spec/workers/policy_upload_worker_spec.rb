require 'spec_helper'
require 'webmock/rspec'

describe BookingWorker, :type => :request do
  before(:each) do
    [ServiceBooking, Service, Client].each do |klass|
      klass.with(safe:true).delete_all
    end

    ResqueSpec.reset!
    Resque.redis.flushall

    Settings.pdp_username = nil
    Settings.pdp_password = nil
  end

  after(:each) do
    Settings.reload!
  end

  it 'should upload the allow_all XML file to the PDP' do
    ResqueSpec.inline = true

    booking = create(:booking_service_booking)

    upload_uri = PolicyUploadWorker.generate_policy_upload_uri(booking.service.service_id, booking.client._id)

    stub_request(:put, upload_uri)

    Resque.enqueue(PolicyUploadWorker, 'allow_all', booking.service.service_id, booking.client._id)

    expect(WebMock).to have_requested(:put, upload_uri).with(
       :body => PolicyUploadWorker.allow_all_policy_xml,
       :headers => {
           'Content-Type' => 'application/xacml+xml'
       }
    )
  end

  it 'should upload the deny_all XML file to the PDP' do
    ResqueSpec.inline = true

    booking = create(:booking_service_booking)

    upload_uri = PolicyUploadWorker.generate_policy_upload_uri(booking.service.service_id, booking.client._id)

    stub_request(:put, upload_uri)

    Resque.enqueue(PolicyUploadWorker, 'deny_all', booking.service.service_id, booking.client._id)

    expect(WebMock).to have_requested(:put, upload_uri).with(
                           :body => PolicyUploadWorker.deny_all_policy_xml,
                           :headers => {
                               'Content-Type' => 'application/xacml+xml'
                           }
                       )
  end

  it 'should upload the allow_all_from_usergroup XML file to the PDP' do
    ResqueSpec.inline = true

    booking = create(:booking_service_booking)

    upload_uri = PolicyUploadWorker.generate_policy_upload_uri(booking.service.service_id, booking.client._id)

    stub_request(:put, upload_uri)

    Resque.enqueue(PolicyUploadWorker, 'allow_all_from_usergroup', booking.service.service_id, booking.client._id, 'Domain Admins')

    expect(WebMock).to have_requested(:put, upload_uri).with(
                           :body => PolicyUploadWorker.allow_all_from_usergroup('Domain Admins'),
                           :headers => {
                               'Content-Type' => 'application/xacml+xml'
                           }
                       )
  end
end