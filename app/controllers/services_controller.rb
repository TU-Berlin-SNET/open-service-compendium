class ServicesController < ApplicationController
  respond_to :html, :xml, :json, :rdf

  def list
    @services = compendium.services
  end

  def show
    @service = compendium.services[params[:id]]
  end
end
