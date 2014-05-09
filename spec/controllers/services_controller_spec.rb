require 'spec_helper'

shared_context 'demo services' do
  before :each do
    4.times do create(:draft_service) end
    3.times do create(:submitted_service) end
    2.times do create(:approved_service) end
    create(:service)
  end

  after :each do
    Service.with(safe: true).delete_all
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

      expect(assigns(:services).length).to eq 2
    end

    it 'lists services with a given status' do
      {'draft' => 4, 'submitted' => 3, 'approved' => 2, 'unknown' => 0}.each do |status, count|
        get :list, {:status => status}

        expect(assigns(:services).length).to eq count
      end
    end
  end

  describe 'POST #create' do
    after :each do
      Service.with(safe: true).delete_all
    end

    it 'creates a new service and loads it to the db and compendium' do
      post :create, {:name => 'my_new_service'}

      service = Service.where(name: 'my_new_service').first

      expect(service).not_to be_nil
      expect(service.sdl_parts['main']).to eql "service_name '#{I18n.t('services.new.service_description_placeholder')}'"
      expect(service.sdl_parts['meta']).to eql 'status draft'

      expect(service.service_name.value).to eql I18n.t('services.new.service_description_placeholder')

      expect(response.status).to eq 201
      expect(response['Location']).to eq service.uri
    end

    it 'creates a new service with the given areas and loads it to the db and compendium' do
      post :create, {:name => 'service_with_sdl_parts', :sdl_parts => {
          'main' => 'can_export csv',
          'meta' => 'status approved'
      }}

      service = Service.where(name: 'service_with_sdl_parts').first

      expect(service.sdl_parts['main']).to eq 'can_export csv'
      expect(service.sdl_parts['meta']).to eq 'status approved'

      expect(service.can_export[0].data_format.identifier).to eq :csv

      expect(response.status).to eq 201
      expect(response['Location']).to eq service.uri
    end

    it 'returns an error, if the service definition is not correct' do
      post :create, {:name => 'service_with_sdl_parts', :sdl_parts => {
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

    it 'retrieves a service' do
      random_service = Service.all.drop(rand(Service.count)).first

      get :show, {:id => random_service.slug}

      expect(response).to be_success
      expect(response.status).to eq(200)

      expect(assigns(:service)).to eq random_service
    end

    it 'errors if it does not find service' do
      get :show, {:id => 'void'}

      expect(response.status).to eq(404)
    end

    it 'returns parts of service descriptions' do
      random_service = Service.all.drop(rand(Service.count)).first

      get :show, {:id => random_service.slug, :sdl_part => 'main', :format => 'sdl'}

      expect(response.status).to eq(200)
      expect(response.body).to eq random_service.sdl_parts['main']
    end

    it 'returns all parts of service descriptions' do
      random_service = Service.all.drop(rand(Service.count)).first

      get :show, {:id => random_service.slug, :format => 'sdl'}

      expect(response.status).to eq(200)
      expect(response.body).to eq random_service.to_service_sdl
    end

    context 'for a historical version' do
      it 'retrieves a historical version of a service' do
        fail pending
      end

      it 'errors if it does not find an historical version' do
        get :show, {:id => 'unknown', :version => 1}

        expect(response.status).to eq(404)
      end

      it 'returns parts of historical service descriptions' do
        historical_service = create(:service_with_history).historical_records[1]

        get :show, {:id => historical_service._id['_id'], :sdl_part => 'main', :format => 'sdl', :version => historical_service._version}

        expect(response.status).to eq(200)
        expect(response.body).to eq historical_service.sdl_parts['main']
      end

      it 'returns all parts of historical service descriptions' do
        historical_service = create(:service_with_history).historical_records[1]

        get :show, {:id => historical_service._id['_id'], :format => 'sdl', :version => historical_service._version}

        expect(response.status).to eq(200)
        expect(response.body).to eq historical_service.to_service_sdl
      end
    end
  end

  describe 'PUT #update' do
    after :each do
      HistoricalServiceRecord.delete_all
    end

    it 'changes the name' do
      service = create(:approved_service)

      put :update, {:id => service.slug, :name => 'changed-name' }

      changed_service = Service.find(service._id)

      expect(changed_service.name).to eql 'changed-name'
    end

    it 'updates one sdl part of the service description' do
      service = create(:approved_service)

      @request.env['RAW_POST_DATA'] = 'service_name "My Service"'
      put :update, {:id => service.slug, :sdl_part => 'main'}

      service.reload

      expect(service.sdl_parts['main']).to eql 'service_name "My Service"'
      expect(service.service_name.value).to eql 'My Service'
    end

    it 'updates all sdl parts of the service description' do
      service = create(:submitted_service)

      put :update, {:id => service.slug, :sdl_parts => {'main' => 'service_name "My Name"', 'meta' => 'status approved'}}

      service.reload

      expect(service.sdl_parts['main']).to eql 'service_name "My Name"'
      expect(service.sdl_parts['meta']).to eql 'status approved'

      expect(service.service_name.value).to eql 'My Name'
      expect(service.status.identifier).to eql :approved
    end

    it 'increments the version and archives the service as historical record' do
      service = create(:approved_service)
      record_sdl_main = service.sdl_parts['main']

      @request.env['RAW_POST_DATA'] = 'service_name "My updated service"'
      put :update, {:id => service.slug, :sdl_part => 'main'}

      service.reload

      expect(service._version).to eq 2

      historical_record = service.historical_records[0]

      expect(historical_record._version).to eq 1
      expect(historical_record.sdl_parts['main']).to eq record_sdl_main
    end

    it 'does not update with erroneous information and gives an error hint' do
      service = create(:approved_service)

      old_main_sdl_part = service.sdl_parts['main']
      old_name = service.service_name.value

      @request.env['RAW_POST_DATA'] = 'unknown'
      put :update, {:id => service.slug, :sdl_part => 'main'}

      service.reload

      expect(response.status).to eq 422
      expect(service.sdl_parts['main']).to eq old_main_sdl_part
      expect(service.service_name.value).to eql old_name
      expect(response.body).to match /'unknown'/
    end
  end

  describe 'GET #list_versions' do
    render_views

    it 'lists all versions' do
      service = create(:service_with_history)

      request.accept = 'application/json'
      get :list_versions, {:id => service._id}

      expect(response.success?).to be true
      expect(assigns(:versions).length).to eq 3

      json_response = JSON[response.body]
      expect(json_response).to be_an Array
      json_response.each do |hash|
        expect{URI.parse(hash['url'])}.not_to raise_exception
        expect{Time.parse(hash['valid_from'])}.not_to raise_exception
        expect(hash['deleted']).to be false
      end
    end
  end

  describe 'DELETE #delete' do
    it 'deletes a service by moving it to the historical service record collection' do
      fail pending
    end
  end

  describe 'DELETE #delete_sdl_part' do
    it 'deletes an SDL part' do
      fail pending
    end
  end
end