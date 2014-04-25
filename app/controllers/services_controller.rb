class ServicesController < ApplicationController
  respond_to :html, :xml, :json, :rdf, :sdl

  before_filter :disable_pretty_printing, :only => [:new, :edit, :create]

  def list
    if params[:status]
      @services = compendium.services.select do |name, service|
        [params[:status]].flatten.include? service.status.status.identifier.to_s
      end
    else
      @services = compendium.approved_services
    end
  end

  def show
    slug = params[:id].split('-')[0]

    @service = compendium.mongo_id_service_map[slug]

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
    @service = compendium.services[params[:id]]

    @service_description = @service.sdl_parts['main']
  end

  def create
    record = ServiceRecord.new ( {
        :name => params[:name],
        :sdl_parts => params[:sdl_parts] || {
            'meta' => 'status draft',
            'main' => "has_name '#{t('services.new.service_description_placeholder')}'"
        }
    })

    record.save

    begin
      record.load_into(compendium)

      head :created, location: record.uri
    rescue Exception => e
      record.delete

      render text: e.message, status: 422
    end

    #redirect_to :action => :edit, :id => record.slug
  end

  def update
    slug = params[:id].split('-')[0]

    service = compendium.mongo_id_service_map[slug]

    if service.nil?
      flash[:message] = t('service.show.service_not_found')
      flash[:error] = t('service.show.service_not_found_detail')

      head :not_found
    else
      if params[:name]
        old_name = compendium.services.key(service)

        compendium.services.delete(old_name)
        compendium.services[params[:name]] = service

        record = ServiceRecord.find(slug)
        record.name = params[:name]
        record.save!
      elsif params[:sdl_part]
        name = compendium.services.key(service.__getobj__)

        current_service = compendium.services.delete(name)

        begin
          new_sdl_parts = current_service.sdl_parts.clone
          new_sdl_parts[params[:sdl_part]] = request.body.read
          new_sdl = ServiceRecord.combine_service_sdl_parts(new_sdl_parts)

          compendium.load_service_from_string(new_sdl, name, current_service.loaded_from)

          record = ServiceRecord.find(slug)
          record.versions << current_service.sdl_parts
          record.sdl_parts = new_sdl_parts
          record.save
        rescue Exception => e
          compendium.services[name] = current_service

          render text: e.message, status: 422

          return
        end
      end
    end

    flash[:message] = t('services.update.successful')
    redirect_to :action => :edit, :id => params[:name] ? "#{params[:id]}-#{params[:name]}" : params[:id]

    #rescue Exception => e
    #  relevant_backtrace = e.backtrace.select do |entry| entry.include? '.service.rb' end
    #
    #  flash.now[:error] = "#{e.message}<br/><pre>#{relevant_backtrace.join("\r\n")}</pre>"
    #  flash.now[:message] = t('services.update.failed')
    #  @error_row = relevant_backtrace[0].match(/.service.rb:(\d+):/)[1].to_i - 1 unless relevant_backtrace.empty?
    #  @service_description = params[:service_description]
    #  render 'edit', :status => 422
    #end
  end

  private
    def disable_pretty_printing
      Slim::Engine.default_options[:pretty] = false
    end
end
