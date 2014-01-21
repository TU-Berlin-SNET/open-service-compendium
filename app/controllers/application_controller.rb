class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :store_current_request

  protected
    def compendium
      Rails.application.compendium
    end

    def store_current_request
      @@current_request = request
    end
end
