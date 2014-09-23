# The PolicyUploadWorker uploads service access policies for certain clients
class PolicyUploadWorker
  @queue = :policy_upload

  def self.perform(access_policy, service_id, client_id, usergroup_name = nil)
    if usergroup_name.present?
      upload_policy_xml(allow_all_from_usergroup(usergroup_name), service_id, client_id)
    else
      upload_policy_xml(send("#{access_policy}_policy_xml"), service_id, client_id)
    end
  end

  def self.upload_policy_xml(policy_xml, service_id, client_id)
    begin
      uri = URI(generate_policy_upload_uri(service_id, client_id))

      Net::HTTP.start(uri.host, uri.port) do |http|
        request = Net::HTTP::Put.new(uri.path.blank? ? '/' : uri.path, {'Content-Type' => 'application/xacml+xml'})

        request.basic_auth(Settings.pdp_username, Settings.pdp_password) if Settings.pdp_username.present?

        response = http.request request, policy_xml

        message_string = "policy for client #{client_id} and service #{service_id}"

        if response.code.eql? "200"
          Rails.logger.info "Successfully uploaded #{message_string}"
        else
          raise Exception.new("Got HTTP #{response.code} code when trying to upload #{message_string}")
        end
      end
    rescue Exception => e
      # We don't handle exceptions
      Rails.logger.error e
    end
  end

  def self.generate_policy_upload_uri(service_id, client_id)
    Settings.pdp_url.gsub(/(:service_id)|(:client_id)/, {':service_id' => service_id, ':client_id' => client_id})
  end

  def self.allow_all_policy_xml
    File.read(Rails.root.join('lib', 'policies', 'allow_all.xml'))
  end

  def self.deny_all_policy_xml
    File.read(Rails.root.join('lib', 'policies', 'deny_all.xml'))
  end

  def self.allow_all_from_usergroup(usergroup_name)
    File.read(Rails.root.join('lib', 'policies', 'allow_all_from_usergroup.xml')).gsub('USERGROUP', usergroup_name)
  end
end