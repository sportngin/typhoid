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

    def parsed_body
      engine.call json_string
    rescue
      raise ReadError, json_string
    end
    private :parsed_body

    def engine
      JSON.method(:parse)
    end
    private :engine
  end

  class ReadError < StandardError
    attr_reader :body
    def initialize(body)
      @body = body
    end

    def to_s
      "Could not parse JSON body: #{cleaned_body}"
    end

    def cleaned_body
      clean = body[0..10]
      clean = clean + "..." if add_dots?
      clean
    end
    private :cleaned_body

    def add_dots?
      body.length > 10
    end
    private :add_dots?
  end
end
