module Typhoid
  class RequestBuilder



  	attr_accessor :klass
    attr_writer :method

  	def initialize(klass, uri, options = {})
  		@uri = uri
  		@request_options = options
  		@klass = klass
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

  end
end

