module Typhoid
  class TyphoeusDecorator < Struct.new(:source)
    def self.decorate(typhoeus_klass)
      @klass_to_decorate = typhoeus_klass
    end

    def self.klass_to_decorate
      @klass_to_decorate
    end

    def self.new(*args, &block)
      if args.first.is_a?(self)
        args.first
      elsif args.first.is_a?(klass_to_decorate)
        super
      else
        super(klass_to_decorate.new(*args, &block))
      end
    end

    def self.method_missing(method_name, *args, &block)
      if klass_to_decorate.respond_to? method_name
        klass_to_decorate.public_send method_name, *args, &block
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
