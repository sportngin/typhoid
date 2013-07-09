require 'typhoeus'
module Typhoid
  class Response < TyphoeusDecorator
    decorate ::Typhoeus::Response
  end
end
