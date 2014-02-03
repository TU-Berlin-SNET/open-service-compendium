class SchemaController < ApplicationController
  def xml_schema
    render :text => SDL::Exporters::XSDSchemaExporter.new(compendium).export_schema
  end

  def cheat_sheet
    @compendium = compendium
  end
end