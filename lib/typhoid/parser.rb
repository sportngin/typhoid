module Typhoid
  class Parser < Struct.new(:body)

    def parse
      ::JSON.parse(body)
    end

    def self.call(body)
      new(body).parse
    end

  end
end
