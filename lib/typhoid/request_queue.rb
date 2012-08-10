require 'typhoeus'

module Typhoid
  class RequestQueue
    attr_reader :queue
    attr_accessor :target

    def initialize(target, hydra = nil)
      @target = target
      @hydra = hydra || Typhoeus::Hydra.new
    end

    def resource(name, req, &block)
      @queue ||= []
      @queue << QueuedRequest.new(@hydra, name, req, @target)
      #@queue[name].on_complete &block if block != nil
    end

    def resource_with_target(name, req, target, &block)
      @queue ||= []
      @queue << QueuedRequest.new(@hydra, name, req, target)
      #@queue[name].on_complete &block if block != nil
    end

    def requests
      @queue ||= []
    end

    def run
      @hydra.run
    end
  end
end
