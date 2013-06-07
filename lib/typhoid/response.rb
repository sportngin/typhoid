require 'typhoeus'
module Typhoid
  class Response < TyphoeusDecorator
    decorate ::Typhoeus::Response

    klass_to_decorate.instance_methods.map { |m| m.to_s.match(/response\_(?<name>\w*)/) }.compact.each do |match|
      define_method match[:name] do
        source.public_send("response_#{match[:name]}")
      end
    end
  end
end
