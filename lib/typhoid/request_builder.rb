module Typhoid
  class RequestBuilder
    attr_accessor :klass
    attr_accessor :request_options
    attr_accessor :request_uri

    attr_writer :method

    def initialize(klass, uri, options = {})
      self.request_uri = uri
      self.request_options = options || {}
      self.klass = klass
    end

    def options
      @request_options.reject { |key,_| key.to_s == "method" }
    end

    def http_method
      request_options[:method] || :get
    end

    def run
      klass.run(self)
    end
  end
end

