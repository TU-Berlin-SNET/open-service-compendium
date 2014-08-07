class BookingWorker
  @queue = :booking

  def self.perform(booking_id, action)
    booking = ServiceBooking.find(booking_id)

    begin
      service = booking.service

      if service.immediate_booking
        booking.update_attributes!(
          endpoint_url: service.immediate_booking.endpoint_url.value,
          booking_status: :booked,
          booked_time: Time.new
        )
      else
        throw Exception('Cannot handle booking types other than immediate booking!')
      end
    rescue Exception => e
      if booking.booking?
        booking.booking_status = :booking_failed
      else
        booking.booking_status = :canceling_failed
      end

      booking.send("#{booking.booking_status}_time=", Time.new)
      booking.failed_reason e.message
    end
  end
end