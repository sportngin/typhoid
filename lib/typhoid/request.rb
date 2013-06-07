require 'typhoeus'
module Typhoid
  class Request < TyphoeusDecorator
    decorate ::Typhoeus::Request

    def response
      compat [:handled_response, :response]
    end
  end
end
