class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  before_filter :set_client_from_tresor_headers
  before_filter :set_tresor_identity

  def default_url_options(options = {})
    { locale: I18n.locale }.merge options
  end

  before_action :set_locale

  def set_locale
    I18n.locale = params[:locale].try(:to_sym) || I18n.default_locale
  end

  protected
    ##
    # Retrieves the compendium
    # @return [SDL::Base::ServiceCompendium] The compendium
    def compendium
      Rails.application.compendium
    end

  private
    def set_client_from_tresor_headers
      tresor_organization = request.headers['TRESOR-Organization'] || Settings.tresor_organization

      if(tresor_organization)
        @client = Client.find_or_create_by(tresor_organization: tresor_organization)
      end
    end

    def set_tresor_identity
      @tresor_identity = request.headers['TRESOR-Identity'] || Settings.tresor_identity || 'REST API'
    end

    def log_remotely(hash)
      Rails.configuration.remote_logger.log Logger::Severity::INFO, hash.merge({
        'priority' => 'INFO',
        'subject-id' => @tresor_identity,
        'client-id' => @client.try(:_id),
        'tresor-component' => 'Broker'
      }) if Rails.configuration.remote_logger
    end
end