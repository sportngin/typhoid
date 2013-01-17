module Typhoid
  class RequestBuilder
    attr_accessor :klass
    attr_writer :method

    def initialize(klass, uri, options = {})
      @uri = uri
      @request_options = options
      @klass = klass
    end

    def ==(other)
      self.class == other.class &&
        klass == other.klass &&
        options_without_method == other.options_without_method &&
        http_method == other.http_method &&
        URI.parse(request_uri) == URI.parse(other.request_uri)
    end

    def request_uri
      @uri
    end

    def options
      @request_options
    end

    def http_method
      options[:method] || :get
    end

    def run
      klass.run(self)
    end

    def options_without_method
      options.clone.tap { |o| o.delete(:method) }
    end
    protected :options_without_method
  end
end

