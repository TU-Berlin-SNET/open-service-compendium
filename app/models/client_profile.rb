# A ClientProfile supports a (very basic) DSL for specifying
# criteria for cloud service selection which are transformed
# to Mongoid queries to be applied in a where statement.
class ClientProfile
  # Methods for returning a Hash to be used within a where
  # statement.
  #
  # Each method returns a Proc which returns a criteria
  # Hash if called with an argument of String containing
  # the property hierarchy, e.g.
  # ('compatible_browsers+browser')
  module Matcher
    def should_be(*args)
      if args[0].respond_to? :identifier
        Proc.new do |property|
          {"#{property}.identifier" => args[0].identifier.to_s}
        end
      else
        Proc.new do |property|
          {"#{property}.serialized_value" => args[0]}
        end
      end
    end

    def should_not_be(*args)
      if args[0].respond_to? :identifier
        Proc.new do |property|
          {"#{property}.identifier" => {'$ne' => args[0].identifier.to_s}}
        end
      else
        Proc.new do |property|
          {"#{property}.serialized_value" => {'$ne' => args[0]}}
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

    def should_not_include(*args)
      args = [args].flatten

      if(args.all?{|p| p.respond_to? :identifier})
        Proc.new do |property|
          {"#{property}.identifier" => {'$nin' => args.collect{|instance| instance.identifier}}}
        end
      else
        Proc.new do |property|
          {"#{property}.serialized_value" => {'$nin' => args}}
        end
      end
    end

    def should_be_at_least(args)
      Proc.new do |property|
        {"#{property}.serialized_value" => {'$gte' => args}}
      end
    end

    def should_be_at_most(args)
      Proc.new do |property|
        {"#{property}.serialized_value" => {'$lte' => args}}
      end
    end

    def should_be_defined
      exists(true)
    end

    def should_not_be_defined
      exists(false)
    end

    private
      def exists(bool)
        Proc.new do |property|
          {"#{property}" => {'$exists' => bool}}
        end
      end
  end

  include Matcher

  class << self
    # This method has to be called in order to use the
    # ClientProfile with the currently loaded SDL
    # vocabulary.
    #
    # It adds two types of methods to the ClientProfile
    # class used while evaluating a client profile:
    # 1. Methods retrieving a predefined type instances
    # 2. Methods named after all properties (recursive)
    #    which provide the target for the matchers.
    def initialize_for_sdl
      SDL::Base::Type.subtypes_recursive.each do |type|
        add_identifier_methods(type)
      end

      define_property_methods(SDL::Base::Type::Service)
    end

    private
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

  # Creates a new client profile and evaluates it to gather
  # the resulting queries.
  #
  # @param [String] client_profile The client profile
  # @raise [ClientProfileError] Raised if the evaluation fails
  def initialize(client_profile)
    @query_statements = []

    begin
      self.instance_eval(client_profile)
    rescue Exception => e
      raise ClientProfileError.new(e)
    end
  end

  # Retrieves all compatible services to this client profile
  # @return [Mongoid::Criteria] The resulting mongoid criteria, ready for querying the database.
  def compatible_services
    Service.latest_with_status(:approved).and(@query_statements)
  end

  # Class representing a client profile error, e.g., the profile
  # is syntactically incorrect.
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