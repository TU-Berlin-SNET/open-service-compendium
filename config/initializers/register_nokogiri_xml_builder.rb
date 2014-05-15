#source: https://gist.github.com/sishen/1019347
require 'action_view'

module ActionView
  module Template::Handlers
    class NokogiriBuilder
      class_attribute :default_format
      self.default_format = Mime::XML

      def call(template)
        require 'nokogiri'
        "xml = ::Nokogiri::XML::Builder.new { |xml| #{template.source} }.to_xml"
      end
    end
  end
end

ActionView::Template.register_template_handler :nokogiri, ActionView::Template::Handlers::NokogiriBuilder.new