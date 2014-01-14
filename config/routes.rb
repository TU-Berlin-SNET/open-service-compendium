OpenServiceBroker::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  get '/', to: redirect('/services')

  get '/service_schema.xsd', to: 'schema#xml_schema', as: :xml_schema

  resources :services do
    get '', on: :collection, action: 'list'
  end
end
