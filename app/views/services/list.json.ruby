services = []

@services.each do |service|
  @exporter ||= SDL::Exporters::JSONExporter.new

  services << @exporter.export_service(service)
end

"[#{services.join(',')}]"