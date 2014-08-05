class ClientsController < ApplicationController
  respond_to :xml

  def index
    @clients = Client.all
  end

  def show

  end

  def create

  end

  def update

  end

  def delete

  end
end