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

      def parse(klass, response)
        if response.success?
          response_body = JSON.parse(response.body)
          if response_body.is_a? Array
            parse_array(klass, response_body)
          else
            parse_single_obj(klass, response_body)
          end
        else
          assign_request_error(klass)
        end
      end

      def load_values(obj, response)
        if response.success?
          response_body = JSON.parse(response.body)
          obj.load_values(response_body)
        else
          assign_request_error(obj.class, obj)
        end
      end

      private

      def parse_array(klass, content)
        values = []
        content.each do |obj|
          values << klass.new(obj)
        end
        values
      end

      def parse_single_obj(klass, content)
        klass.new(content)
      end

      def assign_request_error(klass, obj = nil)
        obj ||= klass.new
        obj.resource_exception = StandardError.new("Could not retrieve data from remote service") #TODO: more specific errors
        obj
      end
    end
  end
end
