class ServicesController < ApplicationController
  respond_to :html, :xml, :json, :rdf, :sdl

  before_filter :disable_pretty_printing, :only => [:new, :edit, :create]

  def list
    @services = compendium.services
  end

  def show
    @service = compendium.services[params[:id]]

    if @service.nil?
      flash[:message] = t('service.show.service_not_found')
      flash[:error] = t('service.show.service_not_found_detail')

      redirect_to :action => :index
    end
  end

  def new
    @header = t('services.new.header')

    render 'edit'
  end

  def edit
    @service = compendium.services[params[:id]]

    @service_description = @service.sdl_parts['main']
  end

  def create
    service_path = File.join(Settings.services_path, "#{params[:symbolic_name].gsub('/', '')}.service.rb")

    File.open(service_path, 'w') do |f|
      f.write("has_name '#{t('services.new.service_description_placeholder')}'")
    end

    compendium.load_service_from_path service_path

    redirect_to :action => :edit, :id => params[:symbolic_name]
  end

  ##
  # Updates a service description.
  #
  #
  #
  # @param [String] symbolic_name The symbolic name of the service, e.g. salesforce_sales_cloud
  # @param [String] service_description The service description
  def update
    original_service_path = File.join(Settings.services_path, "#{params[:id]}.service.rb")
    updated_service_path = File.join(Settings.services_path, "#{params[:symbolic_name]}.service.rb")

    compendium.unload original_service_path

    begin
      compendium.load_service_from_string params[:service_description], params[:symbolic_name], updated_service_path

      File.open(updated_service_path, 'w') do |f|
        f.write params[:service_description]
      end

      unless original_service_path.eql? updated_service_path
        begin
          File.unlink original_service_path
        rescue

        end
      end

      flash[:message] = t('services.update.successful')
      redirect_to :action => :edit, :id => params[:symbolic_name]
    rescue Exception => e
      relevant_backtrace = e.backtrace.select do |entry| entry.include? '.service.rb' end

      flash.now[:error] = "#{e.message}<br/><pre>#{relevant_backtrace.join("\r\n")}</pre>"
      flash.now[:message] = t('services.update.failed')
      @error_row = relevant_backtrace[0].match(/.service.rb:(\d+):/)[1].to_i - 1 unless relevant_backtrace.empty?
      @service_description = params[:service_description]
      render 'edit', :status => 422
    end
  end

  private
    def disable_pretty_printing
      Slim::Engine.default_options[:pretty] = false
    end
end
