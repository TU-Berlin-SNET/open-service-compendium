require 'spec_helper'

describe Service do
  it 'evaluates its SDL parts' do
    record = create(:approved_service)

    expect(record.status.identifier).to eq :approved
  end

  it 'correctly saves and loads' do
    service = create(:approved_service)

    service_id = service._id.to_s

    service.save
    service = nil

    new_service = Service.find(service_id)

    expect(new_service.status).to be_an SDL::Base::Type::Status
  end

  it 'also handles complex SDLs' do
    service = create(:google_drive_service)

    service_id = service._id.to_s

    service.save
    service = nil

    new_service = Service.find(service_id)

    credit_card = SDL::Base::Type::PaymentOption[:credit_card]
    firefox = SDL::Base::Type::Browser[:firefox]

    expect(new_service.payment_options.first).to eql credit_card
    expect(new_service.compatible_browsers.first.browser).to eq firefox
  end

  it 'does not alter predefined types' do
    service = create(:google_drive_service)

    record_id = service._id.to_s

    service.save
    service = nil

    new_service = Service.find(record_id)

    SDL::Base::Type.instances_recursive.each do |sym, instance|
      expect(instance._parent).to be_nil
    end
  end

  it 'serializes lists correctly' do
    service = create(:approved_service)
    service_id = service._id

    compatible_browser_1 = SDL::Base::Type::CompatibleBrowser.new
    compatible_browser_1.browser = SDL::Base::Type::Browser[:firefox].clone
    compatible_browser_2 = SDL::Base::Type::CompatibleBrowser.new
    compatible_browser_2.browser = SDL::Base::Type::Browser[:chrome].clone

    service.compatible_browsers << compatible_browser_1
    service.compatible_browsers << compatible_browser_2

    service.save!

    service = nil

    new_service = Service.find(service_id)
    expect(new_service.compatible_browsers.first.browser).to eq SDL::Base::Type::Browser[:firefox]
  end
end