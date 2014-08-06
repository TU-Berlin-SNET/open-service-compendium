class ServicesController < ApplicationController
  respond_to :html, :xml, :json, :rdf, :sdl

  before_filter :disable_pretty_printing, :only => [:new, :edit, :create]

  def list
    status = params[:status] || :approved

    @services = Service.with(safe: true).with_status(status)
  end

  def list_versions
    slug = params[:id].split('-')[0]

    @versions = HistoricalServiceRecord.where('_id._id' => slug).only(:_id, :_version, :valid_from, :valid_until, :service_deleted)

    respond_to do |format|
      format.html
      format.json { render json: @versions, root: false }
      format.xml
    end
  end

  def show
    slug = params[:id].split('-')[0]

    if params[:version]
      @service = HistoricalServiceRecord.where('_id._id' => slug, '_version' => params[:version]).first
    else
      @service = Service.where('_id' => slug).first
    end
    
    if @service.nil?
      flash[:message] = t('service.show.service_not_found')
      flash[:error] = t('service.show.service_not_found_detail')

      head :not_found

      #redirect_to :action => :index
    end
  end

  def new
    @header = t('services.new.header')

    render 'edit'
  end

  def edit
    slug = params[:id].split('-')[0]

    @service = Service.find(slug)

    @service_description = @service.sdl_parts['main']
  end

  def create
    service = Service.new ( {
        :name => params[:name],
        :sdl_parts => params[:sdl_parts] || {
            'meta' => 'status draft',
            'main' => "service_name '#{t('services.new.service_description_placeholder')}'"
        }
    })

    begin
      service.load_service_from_sdl

      service.save

      head :created, location: service.uri
    rescue Exception => e
      service.delete

      render text: e.message, status: 422
    end

    #redirect_to :action => :edit, :id => record.slug
  end

  def update
    slug = params[:id].split('-')[0]

    service = Service.where(:_id => slug).first
    original_attributes = service.attributes.deep_dup

    if service.nil?
      flash[:message] = t('service.show.service_not_found')
      flash[:error] = t('service.show.service_not_found_detail')

      head :not_found
    else
      if params[:name]
        service.name = params[:name]
        service.archive_and_save!(original_attributes)
      end

      if params[:sdl_part] || params[:sdl_parts]
        begin
          changed = false

          if params[:sdl_part]
            new_part_content = params[:service_description] || request.body.read

            if(service.sdl_parts[params[:sdl_part]] != new_part_content)
              service.sdl_parts[params[:sdl_part]] = new_part_content

              changed = true
            end
          else
            service.sdl_parts = params[:sdl_parts]

            changed = true
          end

          if changed
            service.load_service_from_sdl

            service.archive_and_save!(original_attributes)
          end
        rescue Exception => e
          service.update_attributes! original_attributes

          relevant_backtrace = e.backtrace.select do |entry| entry.include? 'mongodb://' end
          relevant_line = relevant_backtrace[0].match(/:(\d+):/)[1] unless relevant_backtrace.empty?

          render text: "#{e.message}#{relevant_line ? " in line #{relevant_line}" : ''}", status: 422

          return
        end
      end

      flash[:message] = t('services.update.successful')
      redirect_to :action => :edit, :id => params[:name] ? "#{params[:id]}-#{params[:name]}" : params[:id]
    end
  end

  def delete
    slug = params[:id].split('-')[0]

    service = Service.find(slug)

    if service.nil?
      flash[:message] = t('service.show.service_not_found')
      flash[:error] = t('service.show.service_not_found_detail')

      head :not_found
    else
      service.delete_and_archive!

      head :success
    end
  end

  private
    def disable_pretty_printing
      Slim::Engine.default_options[:pretty] = false
    end
end
