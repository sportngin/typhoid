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
      raw_body
    end

    def singular?
      !array?
    end

    def array?
      raw_body.is_a?(Array)
    end

    def raw_body
      engine.call json_string
    rescue
      {}
    end
    private :raw_body

    def engine
      JSON.method(:parse)
    end
    private :engine
  end
end
