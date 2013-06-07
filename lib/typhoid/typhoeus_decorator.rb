module Typhoid
  class TyphoeusDecorator
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
      source_klass.respond_to?(method_name) || super
    end

    def self.inspect
      "#{self.name}Decorator(#{source_klass.name})"
    end

    attr_reader :source

    def initialize(source)
      @source = source
    end

    def ==(other)
      other == source
    end

    def kind_of?(klass)
      super || source.kind_of?(klass)
    end
    alias_method :is_a?, :kind_of?

    def instance_of?(klass)
      super || source.instance_of?(klass)
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

    def inspect
      "#<#{self.class.name} source: (#{source.inspect})>"
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
