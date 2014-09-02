class ServicesController < ApplicationController
  resource_description do
    short 'Services'
    full_description <<-END
The services contained in the Open Service Broker are described using the [SDL-NG framework](https://github.com/TU-Berlin-SNET/sdl-ng), please refer it to get information about the general syntax of the service descriptions. (currently not up-to-date!)

The current vocabulary can be seen [on this page](/schema).

## Service versioning

When `approved` services are updated, new versions are created. A specific service version can be retrieved using `/service/:id/versions/:version_id`. The URL `/service/:id` corresponds to the latest approved, non-deleted version of a service.

## Service statuses

The broker supports two distinct service statuses (`draft` and `approved`) with the following characteristics:

* Only the latest `approved` version of a service will be shown in the service list
* Only `approved` services can be booked
* `approved` services cannot be changed
* Any change to an `approved` service creates a new `draft` version
* There is at most one `draft` version of a service which is newer than the latest `approved` version

## XML data format

|---------+------------+-------------------+-------+-----------|
|Type     |Multiplicity|Name               |Type   |Description|
|---------+------------+-------------------+-------+-----------|
|Attribute|1           |uri                |string |The URL to the specific version of the service.
|Attribute|1           |service_uuid       |UUID   |The UUID of the service on this broker.
|Attribute|1           |version_uuid       |UUID   |The UUID of the specific version on this broker.
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
<versions count="8" service_url="http://test.host/services/e64e00d3-6db0-4a1e-aa12-afc35a3cf905"
          service_uuid="e64e00d3-6db0-4a1e-aa12-afc35a3cf905">
  <version
          url="http://test.host/services/e64e00d3-6db0-4a1e-aa12-afc35a3cf905/versions/dbf91658-6c53-46c1-ac85-c5219a4abe15"
          version_uuid="dbf91658-6c53-46c1-ac85-c5219a4abe15">
    <valid_from>2014-09-02T12:21:31Z</valid_from>
    <status>approved</status>
    <deleted>false</deleted>
  </version>
  <version
          url="http://test.host/services/e64e00d3-6db0-4a1e-aa12-afc35a3cf905/versions/0dcb0d0c-730d-44ac-82c2-15700370d03c"
          version_uuid="0dcb0d0c-730d-44ac-82c2-15700370d03c">
    <valid_from>2014-09-02T11:21:31Z</valid_from>
    <valid_until>2014-09-02T12:21:31Z</valid_until>
    <status>approved</status>
    <deleted>false</deleted>
  </version>
  <version
          url="http://test.host/services/e64e00d3-6db0-4a1e-aa12-afc35a3cf905/versions/9dd9f9e7-cb76-4ae7-8bdc-7f32018b8b76"
          version_uuid="9dd9f9e7-cb76-4ae7-8bdc-7f32018b8b76">
    <status>draft</status>
    <deleted>false</deleted>
  </version>
  <version
          url="http://test.host/services/e64e00d3-6db0-4a1e-aa12-afc35a3cf905/versions/01dd52cd-56a2-404e-bd3e-34c3049379fc"
          version_uuid="01dd52cd-56a2-404e-bd3e-34c3049379fc">
    <status>draft</status>
    <deleted>false</deleted>
  </version>
  <version
          url="http://test.host/services/e64e00d3-6db0-4a1e-aa12-afc35a3cf905/versions/d4cb07d5-e098-4f91-9ea3-4056e97ff3cd"
          version_uuid="d4cb07d5-e098-4f91-9ea3-4056e97ff3cd">
    <valid_from>2014-09-02T08:21:31Z</valid_from>
    <valid_until>2014-09-02T11:21:31Z</valid_until>
    <status>approved</status>
    <deleted>false</deleted>
  </version>
  <version
          url="http://test.host/services/e64e00d3-6db0-4a1e-aa12-afc35a3cf905/versions/ef89291f-36e2-4769-ae32-f922eaf228e5"
          version_uuid="ef89291f-36e2-4769-ae32-f922eaf228e5">
    <status>draft</status>
    <deleted>false</deleted>
  </version>
  <version
          url="http://test.host/services/e64e00d3-6db0-4a1e-aa12-afc35a3cf905/versions/3ea4b47c-75fa-4346-b2ae-62a9288a296f"
          version_uuid="3ea4b47c-75fa-4346-b2ae-62a9288a296f">
    <valid_from>2014-09-02T06:21:31Z</valid_from>
    <valid_until>2014-09-02T08:21:31Z</valid_until>
    <status>approved</status>
    <deleted>false</deleted>
  </version>
  <version
          url="http://test.host/services/e64e00d3-6db0-4a1e-aa12-afc35a3cf905/versions/c8b499f0-1448-445a-b50e-a9fe2b240105"
          version_uuid="c8b499f0-1448-445a-b50e-a9fe2b240105">
    <status>draft</status>
    <deleted>false</deleted>
  </version>
</versions>
~~~
  END
  def list_versions
    @versions = Service.versions(params[:id])

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
  param :sdl_parts, Hash, :desc => 'Parts of the service description.', :required => false do
    param :meta, String, :desc => 'Meta information. Has to contain at least `status`.'
    param :main, String, :desc => 'The main service description'
  end
  description <<-END
The `sdl_parts` `main` and `meta` will be set to defaults if not specified. The `meta` part will default to `status draft` and the `main` part to `service_name '...'` (containing a localized default name).

On successful creation, the method returns the HTTP status code `201 Created` with an HTTP `Location` header. Ths header represents either the service (if approved), or a specific version (if draft).
  END
  error 422, 'Service not created, errors in service description'
  def create
    params[:sdl_parts] = {} if params[:sdl_parts].blank?
    params[:sdl_parts]['meta'] = 'status draft' unless params[:sdl_parts]['meta']
    params[:sdl_parts]['main'] = "service_name '#{t('services.new.service_description_placeholder')}'" unless params[:sdl_parts]['main']

    service = Service.new(:sdl_parts => params[:sdl_parts])

    begin
      service.load_service_from_sdl

      if(service.status.blank?)
        render text: 'sdl_parts["meta"] did not contain a service status', status: 422
      else
        service.save

        if(service.status.identifier == :approved)
          head :created, location: service_url(service.service_id)
        else
          head :created, location: version_service_url(service.service_id, service._id)
        end
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
    if(service.try(:status).try(:identifier) == :draft)
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
            draft_service.load_service_from_sdl(request.path)

            draft_service.save!
          end
        rescue Exception => e
          relevant_backtrace = e.backtrace.select do |entry| entry.include? request.path end
          relevant_line = relevant_backtrace[0].match(/:(\d+):/)[1] unless relevant_backtrace.empty?

          render text: "#{e.message}#{relevant_line ? " in line #{relevant_line}" : ''}", status: 422

          return
        end
      end

      flash[:message] = t('services.update.successful')

      respond_to do |format|
        format.html do
          redirect_to({:action => :edit, :id => params[:id]}, :status => 303)
        end
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
        @service = Service.where(_id: params[:version_id]).first
      end

      if @service.nil?
        render :text => 'Service not found', status: 404
      else
        @service.update_attributes!(:service_deleted => true)

        head :no_content
      end
    else
      Service.where(service_id: params[:id]).set(:service_deleted => true)

      head :no_content
    end
  end

  private
    def disable_pretty_printing
      Slim::Engine.default_options[:pretty] = false
    end
end
