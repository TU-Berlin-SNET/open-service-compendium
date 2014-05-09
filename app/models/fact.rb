class SDL::Base::Fact
  class << self
    def mongoid_relation_name
      name.demodulize.pluralize.underscore.to_sym
    end

    def single_name_alias
      name.demodulize.underscore.to_sym
    end
  end
end