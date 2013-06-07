module Typhoid
  class TyphoeusDecorator < Struct.new(:source)
    def self.decorate(typhoeus_klass)
      @source_klass = typhoeus_klass
    end

    def self.source_klass
      @source_klass
    end

    def self.new(*args, &block)
      if args.first.is_a?(self)
        args.first
      elsif args.first.is_a?(source_klass)
        super
      else
        super(source_klass.new(*args, &block))
      end
    end

    def self.method_missing(method_name, *args, &block)
      if source_klass.respond_to? method_name
        source_klass.public_send method_name, *args, &block
      else
        super
      end
    end

    def self.respond_to?(method_name, include_private = false)
      klass_to_decorate.respond_to?(method_name) || super
    end

    def compat(method_names, *args, &block)
      method_to_call = Array(method_names).find { |method_name| respond_to? method_name }
      if method_to_call
        source.public_send method_to_call, *args, &block
      else
        raise TyphoeusCompatabilityError,
          "Typhoeus API has changed, we don't know how to get response. We know about [:handled_response, :response]"
      end
    end

    def method_missing(method_name, *args, &block)
      if source.respond_to? method_name
        source.public_send method_name, *args, &block
      else
        super
      end
    end

    def respond_to?(method_name, include_private = false)
      source.respond_to?(method_name) || super
    end
  end
end
