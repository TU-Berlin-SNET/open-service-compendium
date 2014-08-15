shared_context 'with client profile examples' do
  before(:each) do
    Client.delete_all
    Service.delete_all
  end

  def self.client_profile_examples()
    {
      'should_be identifier' => {
          profile: 'cloud_service_model should_be saas',
          services: {
              :saas_service => 'cloud_service_model saas',
              :paas_service => 'cloud_service_model paas',
              :iaas_service => 'cloud_service_model iaas'
          },
          included: [:saas_service]
      },
      'should_not_be identifier' => {
          profile: 'cloud_service_model should_not_be saas',
          services: {
              :saas_service => 'cloud_service_model saas',
              :paas_service => 'cloud_service_model paas',
              :iaas_service => 'cloud_service_model iaas'
          },
          included: [:paas_service, :iaas_service]
      },
      'should_be value' => {
          profile: 'established_in should_be 2014',
          services: {
              :new_service => 'established_in 2014',
              :old_service => 'established_in 1984'
          },
          included: [:new_service]
      },
      'should_be boolean value' => {
          profile: 'can_be_used_offline should_be true',
          services: {
              :online_service => 'cloud_service_model saas',
              :offline_service => 'can_be_used_offline true'
          },
          included: [:offline_service]
      },
      'should_not_be value' => {
          profile: 'established_in should_not_be 2014',
          services: {
              :new_service => 'established_in 2014',
              :old_service => 'established_in 1984'
          },
          included: [:old_service]
      },
      'should_include value' => {
          profile: 'service_tags should_include ["a", "c"]',
          services: {
              :abc_service => "service_tag 'a'\r\nservice_tag 'b'\r\nservice_tag 'c'",
              :bd_service => "service_tag 'b'\r\nservice_tag 'd'",
              :c_service => "service_tag 'c'"
          },
          included: [:abc_service, :c_service]
      },
      'should_not_include value' => {
          profile: 'service_tags should_not_include ["a", "c"]',
          services: {
              :abc_service => "service_tag 'a'\r\nservice_tag 'b'\r\nservice_tag 'c'",
              :bd_service => "service_tag 'b'\r\nservice_tag 'd'",
              :c_service => "service_tag 'c'"
          },
          included: [:bd_service]
      },
      'should_include identifier' => {
          profile: 'compatible_browsers_browser should_include firefox',
          services: {
              :ff_service => 'compatible_browser firefox',
              :ieff_service => "compatible_browser firefox\r\ncompatible_browser internet_explorer",
              :ie_service => 'compatible_browser internet_explorer'
          },
          included: [:ff_service, :ieff_service]
      },
      'should_not_include identifier' => {
          profile: 'compatible_browsers_browser should_not_include firefox',
          services: {
              :ff_service => 'compatible_browser firefox',
              :ieff_service => "compatible_browser firefox\r\ncompatible_browser internet_explorer",
              :ie_service => 'compatible_browser internet_explorer'
          },
          included: [:ie_service]
      },
      'should_be_at_least value syntax' => {
          profile: 'provider_employs should_be_at_least 1000',
          services: {
              :small => 'provider do employs 100 end',
              :medium => 'provider do employs 2000 end',
              :large => 'provider do employs 50000 end'
          },
          included: [:medium, :large]
      },
      'should_be_at_most value syntax' => {
          profile: 'provider_employs should_be_at_most 1000',
          services: {
              :small => 'provider do employs 100 end',
              :medium => 'provider do employs 2000 end',
              :large => 'provider do employs 50000 end'
          },
          included: [:small]
      },
      'should_be_defined syntax' => {
          profile: 'cloud_service_model should_be_defined',
          services: {
              :with_service_model => 'cloud_service_model saas',
              :without_service_model => 'compatible_browser firefox'
          },
          included: [:with_service_model]
      },
      'should_not_be_defined syntax' => {
          profile: 'cloud_service_model should_not_be_defined',
          services: {
              :with_service_model => 'cloud_service_model saas',
              :without_service_model => 'compatible_browser firefox'
          },
          included: [:without_service_model]
      }
    }
  end
end