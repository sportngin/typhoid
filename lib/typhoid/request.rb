require 'typhoeus'
module Typhoid
  class Request < TyphoeusDecorator
    decorate ::Typhoeus::Request

    def run
      Typhoid::Response.new source.run
    end

    def response
      compat [:handled_response, :response]
    end

    # Need to force override, because Object#method
    def method
      source.method
    end
  end
end
