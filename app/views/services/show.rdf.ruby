exporter = SDL::Exporters::RDFExporter.new(@service.compendium)

exporter.export_service(@service)