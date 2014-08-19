class ServicesController < ApplicationController
  resource_description do
    short 'Services'
    full_description <<-END
The services contained in the Open Service Broker are described using the [SDL-NG framework](https://github.com/TU-Berlin-SNET/sdl-ng), please refer it to get information about the general syntax of the service descriptions. (currently not up-to-date!)

The current vocabulary can be seen [on this page](/schema).

## Service statuses

The broker supports two distinct statuses: `draft` and `approved`.

## XML data format

|---------+------------+-------------------+-------+-----------|
|Type     |Multiplicity|Name               |Type   |Description|
|---------+------------+-------------------+-------+-----------|
|Attribute|1           |service_version_url|string |The client URL
|Elements |1..n        |_diverse_          |diverse|The service properties, according to the current SDL-NG vocabulary
|---------+------------+-------------------+-------+-----------|

    END
  end

  respond_to :html, :xml, :json, :rdf, :sdl

  before_filter :disable_pretty_printing, :only => [:new, :edit, :create]

  api :GET, 'services', 'Returns a list of services.'
  description <<-END
Without specifying any parameter, the method returns the most-recent, approved and non-deleted versions of all services.

This list can be filtered using the `status` and `deleted` parameters.
  END
  param :status, ['draft', 'approved'], :desc => 'Filter by service status', :required => false
  param :deleted, ['true', 'false'], :desc => 'Also include deleted services', :required => false
  formats ['xml', 'html']
  def list
    status = params[:status] || :approved
    deleted = %w(true True TRUE 1 yes Yes YES).include?(params[:deleted])

    @services = Service.latest_with_status(status, deleted)
  end

  api :GET, 'services/:id/versions', 'List service versions'
  description <<-END
This method lists all versions of a service, their `status`, and their `service_deleted` flag. For any approved version, it lists their `valid_from` and `valid_until` dates, i.e., the timeframe those versions represented the current, non-deleted version.

## Example response
~~~ xml
<?xml version="1.0"?>
<versions count="8">
  <version
          url="http://test.host/services/9243a1db-7f2d-43aa-9c8d-12101fea4a3d/versions/dd55c091-a8f4-4511-bc48-7647d8e8d95d">
    <valid_from>2014-08-19T15:47:09Z</valid_from>
    <status>approved</status>
    <deleted>false</deleted>
  </version>
  <version
          url="http://test.host/services/9243a1db-7f2d-43aa-9c8d-12101fea4a3d/versions/9e67983c-e6a0-488e-a34a-416adbc861de">
    <valid_from>2014-08-19T14:47:09Z</valid_from>
    <valid_until>2014-08-19T15:47:09Z</valid_until>
    <status>approved</status>
    <deleted>false</deleted>
  </version>
  <version
          url="http://test.host/services/9243a1db-7f2d-43aa-9c8d-12101fea4a3d/versions/9b9e7bda-7439-4849-bb62-15ad8177e8e1">
    <status>draft</status>
    <deleted>false</deleted>
  </version>
  <version
          url="http://test.host/services/9243a1db-7f2d-43aa-9c8d-12101fea4a3d/versions/01dec1eb-451f-4d9c-8b1f-691ee690aecb">
    <status>draft</status>
    <deleted>false</deleted>
  </version>
  <version
          url="http://test.host/services/9243a1db-7f2d-43aa-9c8d-12101fea4a3d/versions/3860a58e-1d1d-49b8-83e9-72d712085bad">
    <valid_from>2014-08-19T11:47:09Z</valid_from>
    <valid_until>2014-08-19T14:47:09Z</valid_until>
    <status>approved</status>
    <deleted>false</deleted>
  </version>
  <version
          url="http://test.host/services/9243a1db-7f2d-43aa-9c8d-12101fea4a3d/versions/0f8a7f4a-27af-4f5f-a1a2-e3faac515a56">
    <status>draft</status>
    <deleted>false</deleted>
  </version>
  <version
          url="http://test.host/services/9243a1db-7f2d-43aa-9c8d-12101fea4a3d/versions/76409a34-e25b-465a-8eb6-fec67fd63bb4">
    <valid_from>2014-08-19T09:47:09Z</valid_from>
    <valid_until>2014-08-19T11:47:09Z</valid_until>
    <status>approved</status>
    <deleted>false</deleted>
  </version>
  <version
          url="http://test.host/services/9243a1db-7f2d-43aa-9c8d-12101fea4a3d/versions/a4def45c-b6be-4bc4-801d-34d3001882ef">
    <status>draft</status>
    <deleted>false</deleted>
  </version>
</versions>
~~~
  END
  def list_versions
    @versions = Service.where(service_id: params[:id]).order(updated_at: -1).only(:_id, :service_id, :status, :service_deleted, :created_at, :updated_at).to_a

    @versions.select{|v| (v.status.identifier == :approved) && !v.service_deleted?}.each do |version|
      if(@newer_updated_at)
        newer_updated_at = @newer_updated_at.clone
        version.define_singleton_method :valid_until do
          newer_updated_at
        end
      end

      def version.valid_from
        updated_at
      end

      @newer_updated_at = version.updated_at
    end

    respond_to do |format|
      format.html
      format.xml
    end
  end

  api :GET, 'services/:id[/versions/:version][/:sdl_part]', 'Service retrieval'
  description <<-END
When neither specifying a `version` or an `sdl_part`, the method returns the latest version of a service which is approved and non-deleted.

Historical, draft, or deleted versions can be retrieved using the `version` URL path component.

The service retrieval supports multiple formats:

* `text/html` - Terse HTML representation of a service
* `text/vnd.sdl-ng` - The SDL-NG source of the service description
* `application/xml` - The XML representation of a service
* `application/rdf+xml` - The RDF representation of a service (currently broken)

When querying for the SDL-NG source, the `sdl-part` parameter can be used to retrieve a specific part of the SDL source.
  END
  param :id, String, :desc => 'The service ID', :required => true
  param :version, String, :desc => 'The service version ID', :required => false
  param :sdl_part, String, :desc => 'The part of the service description to return instead of the whole service', :required => false
  formats ['html', 'sdl', 'xml', 'rdf']
  error 404, 'Did not find service, service version or SDL part'
  def show
    if params[:version]
      @service = Service.where('_id' => params[:version]).first
    else
      @service = Service.latest_approved(params[:id])
    end

    if @service.blank?
      flash[:message] = t('service.show.service_not_found')
      flash[:error] = t('service.show.service_not_found_detail')

      render text: 'Service not found', status: 404

      #redirect_to :action => :index
    else
      if params[:sdl_part]
        if @service.sdl_parts[params[:sdl_part]]
          render text: @service.sdl_parts[params[:sdl_part]]
        else
          render text: 'SDL part not found', status: 404
        end
      end
    end
  end

  def new
    @header = t('services.new.header')

    render 'edit'
  end

  def edit
    @service = Service.where(service_id: params[:id]).order(updated_at: -1).first

    @service_description = @service.sdl_parts['main']
  end

  api :POST, 'services', 'Creates a service'
  param :sdl_parts, Hash, :desc => 'Parts of the service description. Simple default applies if not specified.', :required => false do
    param :meta, String, :desc => 'Meta information, e.g. `status`'
    param :main, String, :desc => 'The main service description'
  end
  description <<-END
On successful creation, the method returns the HTTP status code `201 Created` with an HTTP `Location` header. Ths header represents either the service (if approved), or a specific version (if draft).
  END
  error 422, 'Service not created, errors in service description'
  def create
    service = Service.new ( {
        :sdl_parts => params[:sdl_parts] || {
            'meta' => 'status draft',
            'main' => "service_name '#{t('services.new.service_description_placeholder')}'"
        }
    })

    begin
      service.load_service_from_sdl

      service.save

      if(service.status.identifier == :approved)
        head :created, location: service_url(service.service_id)
      else
        head :created, location: version_service_url(service.service_id, service._id)
      end
    rescue Exception => e
      service.delete

      render text: e.message, status: 422
    end
  end

  api :PUT, 'services/:id[/:sdl_part]', 'Updates a service'
  description <<-END
This method can either update the whole service description (using the parameter `sdl_parts`), or update a specific part of a service description (identified by the path component `:sdl_part`). When updating a specific part, the HTTP body is used as the parts contents.

A request for updating an approved service creates a new version of the service. Thus, an approved service will never be changed. The new version will automatically be set to a `draft` status, unless `sdl_parts` contains `status approved`.

If an approved service already has a newer draft version, this version will be the target for further updates until it is approved.

On successful update this method returns 204 No content and a Location header. This location header contains either the URL of a new draft version, or the URL to the service, if a new approved version was created.
  END
  param :sdl_parts, Hash, :desc => 'Updates for the whole service description' do
    param :meta, String, :desc => 'Meta information, e.g. `status`.'
    param :main, String, :desc => 'The main service description'
  end
  param :sdl_part, String, :desc => 'The part of a service description to update'
  error 404, 'Service not found'
  error 422, 'Service description invalid'
  def update
    service = Service.where(:service_id => params[:id]).order(updated_at: -1).first

    draft_service = nil
    if(service.status.identifier == :draft)
      draft_service = service
    else
      draft_service = service.new_draft
    end

    if service.nil?
      flash[:message] = t('service.show.service_not_found')
      flash[:error] = t('service.show.service_not_found_detail')

      render :text => 'Service not found', :status => 404
    else
      if params[:sdl_part] || params[:sdl_parts]
        begin
          changed = false

          if params[:sdl_part]
            new_part_content = request.body.read

            if(draft_service.sdl_parts[params[:sdl_part]] != new_part_content)
              draft_service.sdl_parts[params[:sdl_part]] = new_part_content

              changed = true
            end
          else
            draft_service.sdl_parts = params[:sdl_parts]

            changed = true
          end

          if changed
            draft_service.load_service_from_sdl

            draft_service.save!
          end
        rescue Exception => e
          relevant_backtrace = e.backtrace.select do |entry| entry.include? 'http://' end
          relevant_line = relevant_backtrace[0].match(/:(\d+):/)[1] unless relevant_backtrace.empty?

          render text: "#{e.message}#{relevant_line ? " in line #{relevant_line}" : ''}", status: 422

          return
        end
      end

      flash[:message] = t('services.update.successful')

      respond_to do |format|
        format.html { redirect_to :action => :edit, :id => params[:id] }
        format.any do
          if draft_service.status.identifier == :draft
            head :no_content, location: service_url(draft_service.service_id)
          else
            head :no_content, location: service_version_url(draft_service.service_id, draft_service._id)
          end
        end
      end
    end
  end

  api :DELETE, 'service/:id[/versions/(:version_id|"latest")]', 'Service deletion'
  description <<-END
When not specifying a `version_id` this method deletes all existing versions of a service.

Using the parameter `version_id`, the method can delete a specific version, or the latest version (if specifying `"latest"` as `version_id`).

A service version is never removed from the DB, but marked by the attribute `service_deleted` in the database.
  END
  param :id, String, 'The service ID'
  param :version_id, String, 'The version of a service to delete or "latest" for the latest approved version'
  error 404, 'Service not found'
  def delete
    if params[:version_id]
      if params[:version_id].eql? 'latest'
        @service = Service.latest_approved(params[:id])
      else
        @service = Service.where(_id: params[:id]).first
      end

      if @service.nil?
        render :text => 'Service not found', status: 404
      else
        @service.update_attributes!(:service_deleted => true)

        head :success
      end
    else
      Service.where(service_id: params[:id]).set(:service_deleted => true)

      head :success
    end
  end

  private
    def disable_pretty_printing
      Slim::Engine.default_options[:pretty] = false
    end
end
