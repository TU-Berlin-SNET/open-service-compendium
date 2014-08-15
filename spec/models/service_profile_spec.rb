require 'spec_helper'

describe ClientProfile do
  include_context 'with client profile examples'

  client_profile_examples.each do |syntax, data|
    it "supports '#{syntax}' syntax" do
      client_profile = ClientProfile.new(data[:profile])

      created_services = {}

      data[:services].each do |identifier, sdl|
        created_services[identifier] = create(:service, sdl_parts: {'main' => sdl})
      end

      compatible_services = client_profile.compatible_services

      included_services = created_services.select{|k, v| data[:included].include? k}.values
      not_included_services = (created_services.values - included_services)

      expect(compatible_services.to_a).to include *included_services
      expect(compatible_services.to_a).not_to include *not_included_services
    end
  end
end