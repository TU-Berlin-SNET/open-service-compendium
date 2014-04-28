require 'spec_helper'

shared_context 'demo services' do
  before :each do
    4.times do create(:draft_record).load_into compendium end
    3.times do create(:submitted_record).load_into compendium end
    2.times do create(:approved_record).load_into compendium end
    create(:service_record).load_into compendium
  end

  after :each do
    compendium.services.clear
  end
end

describe ServicesController do
  let 'compendium' do
    Rails.application.compendium
  end

  describe 'GET #list' do
    include_context 'demo services'

    it "responds successfully with an HTTP 200 status code" do
      get :list

      expect(response).to be_success
      expect(response.status).to eq(200)
    end

    it 'does only list approved services' do
      get :list

      expect(assigns(:services).length).to be 2
    end

    it 'lists services with a given status' do
      {'draft' => 4, 'submitted' => 3, 'approved' => 2, 'unknown' => 0}.each do |status, count|
        get :list, {:status => status}
        expect(assigns(:services).length).to be count
      end
    end
  end

  describe 'POST #create' do
    it 'creates a new service record and loads it to the db and compendium' do
      post :create, {:name => 'my_new_service'}

      record = ServiceRecord.where(name: 'my_new_service').first
      service = compendium.services['my_new_service']

      expect(record).not_to be_nil
      expect(record.sdl_parts['main']).to eql "has_name '#{I18n.t('services.new.service_description_placeholder')}'"
      expect(record.sdl_parts['meta']).to eql 'status draft'

      expect(service.name.name.value).to eql I18n.t('services.new.service_description_placeholder')

      expect(response.status).to eq 201
      expect(response['Location']).to eq record.uri

      record.delete
      compendium.services.delete 'my_new_service'
    end

    it 'creates a new service with the given areas and loads it to the db and compendium' do
      post :create, {:name => 'service_with_sdl_parts', :sdl_parts => {
          'main' => 'has_export_capability csv',
          'meta' => 'status approved'
      }}

      record = ServiceRecord.where(name: 'service_with_sdl_parts').first
      service = compendium.services['service_with_sdl_parts']

      expect(record.sdl_parts['main']).to eq 'has_export_capability csv'
      expect(record.sdl_parts['meta']).to eq 'status approved'

      expect(service.export_capabilities[0].format.identifier).to eq :csv

      expect(response.status).to eq 201
      expect(response['Location']).to eq record.uri

      record.delete
      compendium.services.delete 'service_with_sdl_parts'
    end

    it 'returns an error, if the service definition is not correct' do
      post :create, {:name => 'service_with_sdl_parts', :sdl_parts => {
          'main' => 'unknown_fact "unknown value"'
      }}

      expect(ServiceRecord.count).to eq 0
      expect(compendium.services).to be_empty

      expect(response.status).to eq 422
      expect(response.body).to include 'unknown_fact'
    end
  end

  describe 'GET #show' do
    include_context 'demo services'

    render_views

    it 'retrieves a service' do
      random_record = ServiceRecord.all[rand(ServiceRecord.count)]

      get :show, {:id => random_record.slug}

      expect(response).to be_success
      expect(response.status).to eq(200)

      expect(assigns(:service)).to eq compendium.mongo_id_service_map[random_record._id]
    end

    it 'errors if it does not find service' do
      get :show, {:id => 'void'}

      expect(response.status).to eq(404)
    end

    it 'returns parts of service descriptions' do
      random_record = ServiceRecord.all[rand(ServiceRecord.count)]

      get :show, {:id => random_record.slug, :sdl_part => 'main', :format => 'sdl'}

      expect(response.status).to eq(200)
      expect(response.body).to eq random_record.sdl_parts['main']
    end

    it 'returns all parts of service descriptions' do
      random_record = ServiceRecord.all[rand(ServiceRecord.count)]

      get :show, {:id => random_record.slug, :format => 'sdl'}

      expect(response.status).to eq(200)
      expect(response.body).to eq random_record.to_service_sdl
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
        historical_record = create(:service_record_with_history).historical_records[1]

        get :show, {:id => historical_record._id['_id'], :sdl_part => 'main', :format => 'sdl', :version => historical_record._version}

        expect(response.status).to eq(200)
        expect(response.body).to eq historical_record.sdl_parts['main']
      end

      it 'returns all parts of historical service descriptions' do
        historical_record = create(:service_record_with_history).historical_records[1]

        get :show, {:id => historical_record._id['_id'], :format => 'sdl', :version => historical_record._version}

        expect(response.status).to eq(200)
        expect(response.body).to eq historical_record.to_service_sdl
      end
    end
  end

  describe 'PUT #update' do
    it 'changes the name' do
      record = create(:approved_record)
      record.load_into compendium

      put :update, {:id => record.slug, :name => 'changed-name' }

      changed_record = ServiceRecord.find(record._id)

      expect(changed_record.name).to eql 'changed-name'
      expect(compendium.services.key(compendium.mongo_id_service_map[record._id])).to eql 'changed-name'

      changed_record.delete
      compendium.services.clear
    end

    it 'updates one sdl part of the service description' do
      record = create(:approved_record)
      record.load_into compendium

      @request.env['RAW_POST_DATA'] = 'has_name "My Service"'
      put :update, {:id => record.slug, :sdl_part => 'main'}

      record.reload

      expect(record.sdl_parts['main']).to eql 'has_name "My Service"'
      expect(compendium.services[record.name].name.name.value).to eql 'My Service'

      record.delete
      compendium.services.clear
    end

    it 'updates all sdl parts of the service description' do
      record = create(:submitted_record)
      record.load_into compendium

      put :update, {:id => record.slug, :sdl_parts => {'main' => 'has_name "My Name"', 'meta' => 'status approved'}}

      record.reload

      expect(record.sdl_parts['main']).to eql 'has_name "My Name"'
      expect(record.sdl_parts['meta']).to eql 'status approved'

      expect(compendium.services[record.name].name.name.value).to eql 'My Name'
      expect(compendium.services[record.name].status.status.identifier).to eql :approved

      record.delete
      compendium.services.clear
    end

    it 'increments the version and archives the service as historical record' do
      record = create(:approved_record)
      record.load_into compendium
      record_name = record.name
      record_sdl_main = record.sdl_parts['main']

      @request.env['RAW_POST_DATA'] = 'has_name "My updated service"'
      put :update, {:id => record.slug, :sdl_part => 'main'}

      record.reload

      expect(record._version).to eq 2

      historical_record = record.historical_records[0]

      expect(historical_record._version).to eq 1
      expect(historical_record.sdl_parts['main']).to eq record_sdl_main

      record.delete
      historical_record.delete
      compendium.services.clear
    end

    it 'does not update with erroneous information and gives an error hint' do
      record = create(:approved_record)
      record.load_into compendium

      old_main_sdl_part = record.sdl_parts['main']
      old_name = compendium.services[record.name].name.name.value

      @request.env['RAW_POST_DATA'] = 'unknown'
      put :update, {:id => record.slug, :sdl_part => 'main'}

      record.reload

      expect(response.status).to eq 422
      expect(record.sdl_parts['main']).to eq old_main_sdl_part
      expect(compendium.services[record.name].name.name.value).to eql old_name
      expect(response.body).to match /'unknown' in/

      record.delete
      compendium.services.clear
    end
  end

  describe 'GET #list_versions' do
    render_views

    it 'lists all versions' do
      record = create(:service_record_with_history)

      request.accept = 'application/json'
      get :list_versions, {:id => record.id}

      expect(response.success?).to be true
      expect(assigns(:versions).length).to be 3

      json_response = JSON[response.body]
      expect(json_response).to be_an Array
      json_response.each do |hash|
        expect{URI.parse(hash['url'])}.not_to raise_exception
        expect{Time.parse(hash['valid_from'])}.not_to raise_exception
        expect(hash['deleted']).to be false
      end
    end
  end
end