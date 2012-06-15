module Typhoid
  class RequestBuilder



  	attr_accessor :klass

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

  end
end

