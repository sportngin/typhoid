require 'typhoeus'
module Typhoid
  class Request < TyphoeusDecorator
    decorate ::Typhoeus::Request

    def run
      if Typhoid.typhoeus.major_version == 0
        if Typhoid.typhoeus.minor_version >= 6
          response = source.run
        else
          response = Typhoeus::Request.send(method, url, options)
        end
      end
      Typhoid::Response.new response
    end

    def response
      compat [:handled_response, :response]
    end

    # Need to force override, because Object#method
    def method
      source.respond_to?(:method) && source.method || options[:method] || :get
    end
  end
end
