module Typhoid
  class Parser
    attr_reader :json_string

    def self.call(json_string)
      new(json_string).parse
    end

    def initialize(json_string)
      @json_string = json_string
    end

    def parse
      parsed_body
    end

    def singular?
      !array?
    end

    def array?
      parsed_body.is_a?(Array)
    end

    def parsed_body
      engine.call json_string
    rescue
      {}
    end
    private :parsed_body

    def engine
      JSON.method(:parse)
    end
    private :engine
  end
end
