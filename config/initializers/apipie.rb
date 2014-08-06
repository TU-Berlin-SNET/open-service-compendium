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

    (orig + coderay_link).html_safe
  end
end

Apipie.configure do |config|
  config.app_name                = "OpenServiceBroker"
  config.api_base_url            = "/"
  config.doc_base_url            = "/apipie"
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/*.rb"
  config.markup                  = Apipie::Markup::Kramdown.new
  config.reload_controllers      = true
end
