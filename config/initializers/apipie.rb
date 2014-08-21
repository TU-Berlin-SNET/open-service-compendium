class Apipie::Markup::Kramdown
  def initialize
    require 'kramdown'
  end

  def to_html(text)
    Kramdown::Document.new(text).to_html
  end
end

module Apipie::Helpers
  def include_stylesheets
    orig = %w[ bundled/bootstrap.min.css
          bundled/prettify.css
          bundled/bootstrap-responsive.min.css ].map do |file|
      "<link type='text/css' rel='stylesheet' href='#{Apipie.full_url("stylesheets/#{file}")}'/>"
    end.join("\n")

    coderay_link = "<link type='text/css' rel='stylesheet' href='/assets/coderay.css?body=1'/>"
    extra_styles_link = "<link type='text/css' rel='stylesheet' href='/assets/apipie_extra.css?body=1'/>"

    (orig + coderay_link + extra_styles_link).html_safe
  end
end

Apipie.configure do |config|
  config.app_name                = 'Open Service Broker'
  config.api_base_url            = "/"
  config.doc_base_url            = "/apipie"
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/*.rb"
  config.markup                  = Apipie::Markup::Kramdown.new
  config.reload_controllers      = true
  config.validate                = false
  config.app_info = <<-END
# TRESOR Open Service Broker

## Main functionality

The TRESOR Open Service Broker is an information system realizing the following main functions:

* Managing service descriptions, clients, and providers
* Performing booking of services

## Format of parameters

All described parameters can be sent using these methods:

* Sending parameters within the HTTP body, `multipart/form-data` encoded (on POST & PUT methods)
* Sending parameters as a query string (on all methods)

Both methods can be combined, e.g. sending one parameter in the query string and another as `multipart/form-data`.
  END
end
