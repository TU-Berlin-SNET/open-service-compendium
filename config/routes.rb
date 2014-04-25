OpenServiceBroker::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  get '/', to: redirect('/services')

  get '/service_schema.xsd', to: 'schema#xml_schema', as: :xml_schema
  get '/schema', to: 'schema#cheat_sheet', as: :cheat_sheet

  resources :services do
    get '', on: :collection, action: 'list'
    get ':sdl_part', on: :member, action: 'show'
    put ':sdl_part', on: :member, action: 'update'
  end
end
