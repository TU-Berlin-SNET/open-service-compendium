graph = RDF::Graph.new

@services.each do |service|
  SDL::Exporters::RDFExporter.expand_properties(service, graph)
end

graph.dump(:rdf)