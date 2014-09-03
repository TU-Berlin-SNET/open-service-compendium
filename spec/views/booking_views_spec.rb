require 'spec_helper'

describe 'bookings/index.xml.nokogiri' do
  it 'gives out an xml document with all bookings' do
    ServiceBooking.with(safe: true).delete_all

    service_bookings = create(:client, :with_bookings).service_bookings

    assign(:bookings, service_bookings)

    render

    expect {
      @xml = Nokogiri::XML(rendered)
    }.not_to raise_exception

    expect(@xml.root.name).to eq 'bookings'
    expect(@xml.root['count']).to eq @xml.root.elements.count.to_s

    service_bookings.each do |booking|
      expect(@xml.xpath("/bookings/booking[@url = '#{client_booking_url(booking.client, booking)}']")).to have_exactly(1).node
    end
  end
end

describe 'bookings/show.xml.nokogiri' do
  it 'gives out an xml document with the specified booking' do
    ServiceBooking.with(safe: true).delete_all

    booking = create(:canceling_failed_service_booking)

    assign(:booking, booking)

    render

    expect {
      @xml = Nokogiri::XML(rendered)
    }.not_to raise_exception

    expect(@xml.root.name).to eq 'booking'
    expect(@xml.xpath('/booking/@url').first.value).to eq client_booking_url(booking.client, booking)
  end
end