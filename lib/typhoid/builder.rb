module Typhoid
  class Builder
    attr_reader :klass
    attr_reader :response
    attr_reader :body
    attr_reader :parsed_body

    def self.call(klass, response)
      new(klass, response).build
    end

    def initialize(klass, response)
      @klass = klass
      @response = response
      @body = response.body
      @parsed_body = parser.call body
    end

    def build
      array? ? build_array : build_single
    end

    def build_from_klass(attributes)
      klass.new(attributes).tap { |item|
        item.after_build(response) if item.respond_to? :after_build
      }
    end
    private :build_from_klass

    def array?
      parsed_body.is_a?(Array)
    end
    private :array?

    def build_array
      parsed_body.collect { |single|
        build_from_klass(single)
      }
    end
    private :build_array

    def build_single
      build_from_klass parsed_body
    end
    private :build_single

    def parser
      klass.parser
    end
    private :parser
  end
end
