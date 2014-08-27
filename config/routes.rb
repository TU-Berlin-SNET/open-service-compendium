OpenServiceBroker::Application.routes.draw do
  if Rails.env.production?
    default_url_options(host: 'tresor-dev-broker.snet.tu-berlin.de')
  elsif Rails.env.test?
    default_url_options(host: 'test.host')
  else
    default_url_options(host: 'dev.host')
  end

  apipie
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  get '/', to: redirect('/services')

  get '/service_schema.xsd', to: 'schema#xml_schema', as: :xml_schema
  get '/schema', to: 'schema#cheat_sheet', as: :cheat_sheet

  resources :services do
    get '', on: :collection, action: 'list'
    get 'edit', on: :member, action: 'edit'

    get 'versions', on: :member, action: 'list_versions'
    get 'versions/:version', on: :member, action: 'show', as: :version
    delete 'versions/:version_id', on: :member, action: 'delete'
    get 'versions/:version/:sdl_part', on: :member, action: 'show'

    get ':sdl_part', on: :member, action: 'show', as: :sdl_part_of
    put ':sdl_part', on: :member, action: 'update', constraints: { sdl_part: /(?!edit).*/}
    delete '', on: :member, action: 'delete'
  end

  resources :clients do
    get 'compatible_services', on: :member, action: 'compatible_services'

    resources :bookings
  end

  resources :providers, defaults: {format: 'xml'}
end
