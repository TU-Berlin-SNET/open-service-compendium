class ClientProfile
  module Matcher
    def should_be(*args)
      if args[0].respond_to? :identifier
        Proc.new do |property|
          {"#{property}.identifier" => args[0].identifier.to_s}
        end
      else
        Proc.new do |property|
          {property => args[0]}
        end
      end
    end

    def should_include(*args)
      args = [args].flatten

      if(args.all?{|p| p.respond_to? :identifier})
        Proc.new do |property|
          {"#{property}.identifier" => {'$in' => args.collect{|instance| instance.identifier}}}
        end
      else
        Proc.new do |property|
          {"#{property}.serialized_value" => {'$in' => args}}
        end
      end
    end
  end

  include Matcher

  class << self
    def initialize_for_sdl
      SDL::Base::Type.subtypes_recursive.each do |type|
        add_identifier_methods(type)
      end

      define_property_methods(SDL::Base::Type::Service)
    end

    def add_identifier_methods(type)
      type.instances.each do |symbol, instance|
        define_method(symbol) do
          instance
        end unless method_defined?(symbol)
      end
    end

    def define_property_methods(type, prefix = '')
      type.properties(true).each do |property|
        define_method "#{prefix.gsub('+', '_')}#{property.name}" do |*args|
          @query_statements << args[0].call(prefix.gsub('+', '.') + property.name)
        end unless method_defined?("#{prefix.gsub('+', '_')}#{property.name}")

        if property.type.respond_to? :properties
          define_property_methods(property.type, "#{property.name}+")
        end
      end
    end
  end

  def initialize(client_profile)
    @query_statements = []

    begin
      self.instance_eval(client_profile)
    rescue Exception => e
      raise ClientProfileError.new(e)
    end
  end

  def compatible_services
    Service.and(@query_statements)
  end

  class ClientProfileError < Exception
    def initialize(cause)
      @cause = cause
    end

    def cause
      @cause
    end

    def to_s
      "Client profile error: #{@cause.message}"
    end
  end
end