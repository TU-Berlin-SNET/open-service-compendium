class SchemaController < ApplicationController
  def xml_schema
    render :text => BrokerXSDSchemaExporter.new(compendium).export_schema
  end

  def cheat_sheet
    @compendium = compendium
  end

  def service_properties

  end
end