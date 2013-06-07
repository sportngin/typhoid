module Typhoid
  class QueuedRequest
    attr_accessor :name, :request, :target, :klass
    attr_accessor :on_complete

    def initialize(hydra, name, req, target)
      self.name = name
      self.request = Request.new(req.request_uri, req.options)
      self.klass = req.klass
      self.target = target
      hydra.queue(self.request)
    end

    def on_complete
      self.request.on_complete do
        yield self if block_given?
      end
    end

    def status
      response.code
    end

    def response
      self.request.response
    end

    def klass
      @klass
    end
  end
end
