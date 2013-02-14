module Typhoid
  class Builder
    attr_reader :klass
    attr_reader :response
    attr_reader :body
    attr_reader :parsed
    attr_reader :parsed_body

    def self.call(klass, response)
      new(klass, response).build
    end

    def initialize(klass, response)
      @klass = klass
      @response = response
      @body = response.body
      @parsed = parse
      @parsed_body = parsed.parse
    end

    def build
      parsed.singular? ? build_single : build_array
    end

    def build_from_klass(attributes)
      klass.new(attributes).tap { |item|
        item.after_build(response) if item.respond_to? :after_build
      }
    end
    private :build_from_klass

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

    def parse
      parser.new body
    end
    private :parse

    def parser
      Parser
    end
    private :parser
  end
end
