require 'spec_helper'

shared_context 'demo services' do
  before :each do
    Service.with(safe: true).delete_all

    4.times do
      create(:draft_service)
      create(:draft_service, :deleted)
    end

    2.times do
      create(:approved_service, :with_older_versions)
      create(:approved_service, :with_older_versions, :deleted)
    end

    create(:service)
    create(:service, :deleted)

    Service.all.to_a
  end
end

describe ServicesController do
  describe 'GET #list' do
    include_context 'demo services'

    it "responds successfully with an HTTP 200 status code" do
      get :list

      expect(response).to be_success
      expect(response.status).to eq(200)
    end

    it 'does only list approved services' do
      get :list

      expect(assigns(:services)).to have_exactly(2).services
    end

    it 'lists the latest services with a given status' do
      {'draft' => 6, 'approved' => 2, 'unknown' => 0}.each do |status, count|
        get :list, {:status => status}

        expect(assigns(:services)).to have_exactly(count).services
      end
    end

    it 'lists only deleted services' do
      get :list, :deleted => 'true'

      expect(assigns(:services)).to have_exactly(2).service
    end
  end

  describe 'POST #create' do
    before :each do
      Service.with(safe: true).delete_all
    end

    it 'creates a new service and loads it to the db and compendium' do
      post :create, :format => :xml

      service = Service.first

      expect(service).not_to be_nil
      expect(service.sdl_parts['main']).to eql "service_name '#{I18n.t('services.new.service_description_placeholder')}'"
      expect(service.sdl_parts['meta']).to eql 'status draft'

      expect(service.service_name.value).to eql I18n.t('services.new.service_description_placeholder')

      expect(response.status).to eq 201
      expect(response['Location']).to eq version_service_url(service.service_id, service._id)
    end

    it 'creates a new service with the given areas and loads it to the db and compendium' do
      post :create, {:sdl_parts => {
          'main' => 'exportable_data_format csv',
          'meta' => 'status approved'
      }, :format => :xml}

      service = Service.first

      expect(service.sdl_parts['main']).to eq 'exportable_data_format csv'
      expect(service.sdl_parts['meta']).to eq 'status approved'

      expect(service.exportable_data_formats[0].identifier).to eq :csv

      expect(response.status).to eq 201
      expect(response['Location']).to eq service_url(service.service_id)
    end

    it 'sets the status to draft if only given sdl_parts[main]' do
      post :create, {
          :sdl_parts => {
              'main' => 'exportable_data_format csv'
          }, :format => :xml
      }

      service = Service.first

      expect(service.sdl_parts['main']).to eq 'exportable_data_format csv'
      expect(service.sdl_parts['meta']).to eq 'status draft'

      expect(service.exportable_data_formats[0].identifier).to eq :csv
      expect(service.status.identifier).to eq :draft

      expect(response.status).to eq 201
      expect(response['Location']).to eq version_service_url(service.service_id, service._id)
    end

    it 'sets a default name if only given sdl_parts[meta]' do
      post :create, {
          :sdl_parts => {
              'meta' => 'status approved'
          }, :format => :xml
      }

      service = Service.first

      expect(service.sdl_parts['main']).to match /service_name '.+'/
      expect(service.sdl_parts['meta']).to eq 'status approved'

      expect(service.status.identifier).to eq :approved

      expect(response.status).to eq 201
      expect(response['Location']).to eq service_url(service.service_id)
    end

    it 'does not create a service without a status' do
      post :create, {
          :sdl_parts => {
              'meta' => 'provider_id "123456"'
          }, :format => :xml
      }

      expect(response.status).to eq 422
    end

    it 'sends the relevant URI as HTTP location header' do
      post :create, {:sdl_parts => {
          'main' => 'service_name "ABC"',
          'meta' => 'status approved'
      }, :format => :xml}

      service = Service.first

      service_uri = response['Location']
      assert_generates(service_uri, {:controller => 'services', :action => 'show', :id => service.service_id})
    end

    it 'returns an error, if the service definition is not correct' do
      post :create, {:sdl_parts => {
          'main' => 'unknown "unknown"'
      }}

      expect(Service.count).to eq 0

      expect(response.status).to eq 422
      expect(response.body).to include 'unknown'
    end
  end

  describe 'GET #show' do
    include_context 'demo services'

    render_views

    let :random_service do
      Service.latest_with_status('approved').drop(rand(Service.latest_with_status('approved').count)).first
    end

    it 'retrieves a service' do
      get :show, {:id => random_service.service_id}

      expect(response).to be_success
      expect(response.status).to eq(200)

      expect(assigns(:service)).to eq random_service
    end

    it 'errors if it does not find service' do
      get :show, {:id => 'void'}

      expect(response.status).to eq(404)
    end

    it 'errors if it does not find an SDL part' do
      get :show, :id => random_service.service_id, :sdl_part => 'nonexisting'

      expect(response.status).to eq(404)
    end

    it 'does not show a service which has only a draft version' do
      draft_service = create(:draft_service)

      get :show, {:id => draft_service.service_id}

      expect(response.status).to eq(404)
    end

    it 'returns parts of service descriptions' do
      get :show, {:id => random_service.service_id, :sdl_part => 'main', :format => 'sdl'}

      expect(response.status).to eq(200)
      expect(response.body).to eq random_service.sdl_parts['main']
    end

    it 'returns all parts of service descriptions CRLF encoded' do
      get :show, {:id => random_service.service_id, :format => 'sdl'}

      expect(response.status).to eq(200)
      expect(response.body).to eq random_service.to_service_sdl
      expect(response.body.count("\r\n")).to eql 19
    end

    context 'for a historical version' do
      it 'retrieves a historical version of a service' do
        service = create(:approved_service, :with_older_versions)
        old_version = Service.where(:service_id => service.service_id, 'status.identifier' => 'draft').order(:created_at => 1).first

        get :show, {:id => service.service_id, :version => old_version._id}
        expect(assigns(:service).status.identifier).to eq :draft

        get :show, {:id => service.service_id}
        expect(assigns(:service).status.identifier).to eq :approved
      end

      it 'errors if it does not find an historical version' do
        get :show, {:id => 'unknown', :version => 1}

        expect(response.status).to eq(404)
      end

      it 'returns parts of historical service descriptions' do
        service = create(:approved_service, :with_older_versions)
        old_version = Service.where(:service_id => service.service_id, 'status.identifier' => 'draft').order(:created_at => 1).first

        get :show, {:id => service.service_id, :sdl_part => 'main', :format => 'sdl', :version => old_version._id}

        expect(response.status).to eq(200)
        expect(response.body).to eq old_version.sdl_parts['main']
      end

      it 'returns all parts of historical service descriptions' do
        service = create(:approved_service, :with_older_versions)
        old_version = Service.where(:service_id => service.service_id, 'status.identifier' => 'draft').order(:created_at => 1).first

        get :show, {:id => service.service_id, :format => 'sdl', :version => old_version._id}

        expect(response.status).to eq(200)
        expect(response.body).to eq old_version.to_service_sdl
      end
    end
  end

  describe 'PUT #update' do
    before :each do
      Service.with(safe: true).delete_all
    end

    it 'updates one sdl part of the service description and sets status to draft' do
      service = create(:approved_service)

      old_service_name = service.service_name.value

      @request.env['RAW_POST_DATA'] = 'service_name "My Service"'
      put :update, {:id => service.service_id, :sdl_part => 'main'}

      service.reload

      expect(service.service_name.value).to eql old_service_name
      expect(service.status).to eql SDL::Base::Type::Status[:approved]

      new_draft = Service.where(:service_id => service.service_id).order(:updated_at => -1).first

      expect(new_draft.sdl_parts['main']).to eql 'service_name "My Service"'
      expect(new_draft.service_name.value).to eql 'My Service'
      expect(new_draft.status).to eql SDL::Base::Type::Status[:draft]
    end

    it 'updates all sdl parts of the service description' do
      service = create(:draft_service)

      put :update, {:id => service.service_id, :sdl_parts => {'main' => "service_name 'My Name'\r\nservice_tag 'other-tag'", 'meta' => 'status approved'}}

      service.reload

      expect(service.sdl_parts['main']).to eql "service_name 'My Name'\r\nservice_tag 'other-tag'"
      expect(service.sdl_parts['meta']).to eql 'status approved'

      expect(service.service_name.value).to eql 'My Name'
      expect(service.status.identifier).to eql :approved
      expect(service.service_tags.count).to eql 1
    end

    it 'does not update with erroneous information and gives an error hint' do
      service = create(:approved_service)

      old_main_sdl_part = service.sdl_parts['main']
      old_name = service.service_name.value

      @request.env['RAW_POST_DATA'] = 'unknown'
      put :update, {:id => service.service_id, :sdl_part => 'main'}

      service.reload

      expect(response.status).to eq 422
      expect(service.sdl_parts['main']).to eq old_main_sdl_part
      expect(service.service_name.value).to eql old_name
      expect(response.body).to match /'unknown'/
    end

    it 'redirects to the draft version if status is draft' do
      service = create(:approved_service)

      put :update, {:id => service.service_id, :sdl_parts => {:main => 'service_name "Changed name"'}, :format => :xml}

      latest_draft = Service.latest_draft(service.service_id)

      expect(response.status).to eq 204
      expect(response['Location']).to eq version_service_url(service.service_id, latest_draft._id)
    end

    it 'redirects to the service if status is approved' do
      service = create(:draft_service)

      put :update, {:id => service.service_id, :sdl_parts => {:meta => 'status approved'}, :format => :xml}

      expect(response.status).to eq 204
      expect(response['Location']).to eq service_url(service.service_id)
    end
  end

  describe 'GET #list_versions' do
    render_views

    it 'lists all versions' do
      service = create(:approved_service, :with_older_versions)

      get :list_versions, {:id => service.service_id, :format => :xml}

      expect(response).to be_success
      expect(assigns(:versions).length).to eq 8
    end
  end

  describe 'DELETE #delete' do
    it 'deletes all versions of a service' do
      service = create(:approved_service, :with_older_versions)

      delete :delete, {:id => service.service_id, :format => :xml}

      expect(response.status).to eq(204)

      expect(Service.where(service_id: service.service_id).all? { |s| s.service_deleted? })
    end

    it 'deletes a specific version of a service' do
      service = create(:approved_service, :with_older_versions)

      old_version = Service.where(:service_id => service.service_id).order(:created_at => 1).first

      delete :delete, {:id => service.service_id, :version_id => old_version._id, :format => :xml}

      [service, old_version].each &:reload

      expect(response.status).to eq(204)

      expect(service.service_deleted?).to be false
      expect(old_version.service_deleted?).to be true
    end

    it 'deletes the latest version of a service' do
      service = create(:approved_service, :with_older_versions)
      older_versions = Service.where(:service_id => service.service_id, :id => {'$ne' => service._id})

      delete :delete, {:id => service.service_id, :version_id => 'latest', :format => :xml}

      service.reload

      expect(response.status).to eq(204)

      expect(service.service_deleted?).to be true
      expect(older_versions.none?{|s| s.service_deleted?}).to be true
    end
  end

  describe 'GET #uuid' do
    before(:each) do
      Service.delete_all
    end

    render_views

    it 'retrieves the UUID for a service' do
      service = create(:approved_service)
      service.update_attributes!(name: 'my-service')

      get :uuid, {:name => 'my-service'}

      expect(response).to be_success
      expect(response.body).to eq(service.service_id)
    end

    it 'returns 404 if it does not find a service' do
      get :uuid, {:name => 'other-service'}

      expect(response.status).to eq(404)
    end
  end
end