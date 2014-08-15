class SDL::Receivers::ServiceRecordReceiver < SDL::Receivers::ServiceReceiver
  def initialize(record, compendium)
    @compendium = compendium

    @service = record

    compendium.fact_classes.each do |fact_class|
      fact_class.keywords.each do |keyword|
        define_singleton_method keyword do |*args, &block|
          add_fact fact_class, *args, &block
        end
      end
    end
  end
end
