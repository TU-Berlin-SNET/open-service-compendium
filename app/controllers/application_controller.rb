class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  protected
    ##
    # Retrieves the compendium
    # @return [SDL::Base::ServiceCompendium] The compendium
    def compendium
      Rails.application.compendium
    end
end
