source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.1.2'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

#gem 'sdl-ng', :path => 'lib/sdl-ng', require: false

gem 'slim', github: 'slim-template/slim'

# SDL-NG is included as a 'library' to support development class reloading
# That means, that we need to require its gems for the broker
gemspec path: 'lib/sdl-ng'

# Rails config
gem 'config'

gem 'radix', github: 'asalme/radix', branch: 'master'

gem 'thin'

gem 'mongoid', '~> 4.0'
gem 'mongoid-enum', github: 'thetron/mongoid-enum', ref: '2288e'

group :development, :test do
  gem 'rspec-rails', '~> 3.3'
  gem 'rspec-collection_matchers'
end

group :test do
  gem 'database_cleaner', :github => 'bmabey/database_cleaner'
  gem 'factory_girl'
  gem 'humanize'
  gem 'zeus'
  gem 'minitest'
  gem 'simplecov'
  gem 'resque_spec'
  gem 'webmock'
end

gem 'active_model_serializers'

gem 'apipie-rails', github: 'Apipie/apipie-rails'

gem 'kramdown'
gem 'coderay'

gem 'capistrano', '~> 3.2.0'
gem 'capistrano-bundler'
gem 'capistrano-rails'
gem 'capistrano-rvm'
gem 'capistrano-resque', require: false
gem 'resque'
gem 'logstash-logger'

gem 'draper'
gem 'awesome_print'

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'responders', '~> 2.0'
