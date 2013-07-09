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
      symbolize_keys({ method: http_method }.merge(request_options.reject { |_,value| value.nil? }))
    end

    def http_method
      request_options[:method] || :get
    end

    def run
      klass.run(self)
    end

    private

    # Ethon hates on hash with indifferent access for some reason
    def symbolize_keys(hash)
      hash = hash.to_hash
      if hash.respond_to?(:symbolize_keys)
        hash.symbolize_keys
      else
        hash.inject({}) do |new_hash, (key, value)|
          new_hash[symbolize_key(key)] = value
          new_hash
        end
      end
    end

    def symbolize_key(key)
      return key if key.is_a?(Symbol)
      key.to_s.to_sym
    end
  end
end

