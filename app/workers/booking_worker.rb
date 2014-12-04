require 'nokogiri'

# The BookingWorker performs the tasks needed in order to provision services
# to fulfill client bookings.
#
# These are dependent on the booking information in the services. Therefore,
# the BookingWorker contains methods named after the booking types and actions,
# e.g.: book_immediate_booking(booking) or cancel_synchronous_booking(booking).
class BookingWorker
  @queue = :booking

  class << self
    include Rails.application.routes.url_helpers
  end

  def self.perform(host, booking_id, action)
    # This would introduce a concurrency issue, if some bookings
    # would originate from requests to different HTTP hosts.
    Rails.application.routes.default_url_options[:host] = host

    booking = ServiceBooking.find(booking_id)

    begin
      service = booking.service

      SDL::Base::Type::Booking.subtypes.map(&:local_name).map(&:underscore).each do |type|
        if service.send(type)
          send("#{action}_#{type}", booking)

          notify_callback_url(booking) if booking.callback_url

          message = action.eql?('book') ? "Finished booking #{booking._id}!" : "Canceled booking #{booking._id}!"

          log_remotely 'INFO', message, booking
        end
      end
    rescue Exception => e
      if booking.booking?
        booking.booking_status = :booking_failed

        log_remotely 'ERROR', "Booking #{booking._id} failed!", booking
      else
        booking.booking_status = :canceling_failed

        log_remotely 'ERROR', "Canceling #{booking._id} failed!", booking
      end

      booking.send("#{booking.booking_status}_time=", Time.new)
      booking.failed_reason = e.message
    end
  end

  def self.book_immediate_booking(booking)
    booking.update_attributes!(
        endpoint_url: booking.service.immediate_booking.endpoint_url.value,
        booking_status: :booked,
        booked_time: Time.new
    )
  end

  def self.cancel_immediate_booking(booking)
    booking.update_attributes!(
        booking_status: :canceled,
        canceled_time: Time.new
    )
  end

  def self.notify_callback_url(booking)
    booking_xml = ::Nokogiri::XML::Builder.new do |xml|
      eval(File.read(File.expand_path('../views/bookings/_booking.xml.nokogiri', File.dirname(__FILE__))), binding)
    end.to_xml

    begin
      uri = URI(booking.callback_url)

      Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https', :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
        http.request_post(uri.path.blank? ? '/' : uri.path, booking_xml, {'Content-Type' => 'application/xml'})
      end
    rescue Exception => e
      # We don't handle exceptions in callback URL notifications
      logger.error e.message + "\n " + e.backtrace.join("\n ")
    end
  end

  def self.log_remotely(priority_string, msg, booking)
    priority = Logger::Severity.constants.find{ |name| Logger::Severity.const_get(name) == priority_string }

    Rails.configuration.remote_logger.log priority, {
      :message => "#{msg} (Service '#{booking.service.service_name.value}' - version #{booking.service.service_id} of service #{booking.service.service_id})",
      :category => 'Service booking',
      :priority => priority_string,
      'subject-id' => 'Broker',
      'tresor-component' => 'Broker',
      'client-id' => booking.client._id
    } if Rails.configuration.remote_logger
  end
end