module Typhoid
  module Attributes
    attr_reader :attributes

    def load_values(params = {})
      @attributes = Hash[params.map { |key, value| [key.to_s, value] }]
    end

    def read_attribute(name)
      attributes[name.to_s]
    end
    alias :[] :read_attribute

    def after_build(response, exception = nil)
      assign_request_error(exception) if !response.success? || !exception.nil?
    end

    def assign_request_error(exception = nil)
      self.resource_exception = exception || StandardError.new("Could not retrieve data from remote service")
    end
    private :assign_request_error

    def self.included(base)
      base.extend(ClassMethods)
    end

    protected

    module ClassMethods
      def field(*field_names)
        raise ArgumentError, "Must specify at least one field" if field_names.length == 0
        @auto_init_fields ||= []
        field_names.each do |field_name|
          define_accessor field_name
          @auto_init_fields << field_name.to_sym
        end
      end

      def define_accessor(field_name)
        define_method field_name do
          @attributes[field_name.to_s]
        end
        define_method "#{field_name}=" do |new_value|
          @attributes[field_name.to_s] = new_value
        end
      end
      private :define_accessor

      def auto_init_fields
        @auto_init_fields || []
      end

      def builder
        Builder
      end

      def parser
        Parser
      end

      def parse(klass, response)
        builder.call(klass, response)
      end

      def load_values(object, response)
        object.tap { |obj|
          obj.load_values(parser.call response.body)
          obj.after_build response
        }
      end
    end
  end
end
