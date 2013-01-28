require 'cgi'

module Typhoid
  class Resource
    include Typhoid::Multi
    include Typhoid::Attributes

    class << self
      attr_accessor :site, :path
    end

    attr_accessor :resource_exception

    def self.build_request(uri, options = {})
      Typhoid::RequestBuilder.new(self, uri, options)
    end

    def self.run(request)
      method = request.http_method
      parse(request.klass, (Typhoeus::Request.send method, request.request_uri, request.options))
    end

    def initialize(params = {})
      load_values(params)
    end

    def save!(method = nil)
      response = save_request(method).run
      self.class.load_values(self, response)
    end

    def destroy!
      response = Typhoeus::Request.delete(delete_request.request_uri, delete_request.options)
      self.class.load_values(self, response)
    end

    def save_request(method = nil)
      new_record? ? create_request(method) : update_request(method)
    end

    def save_http_method(method = nil)
      if method
        method
      else
        (new_record?) ? :post : :put
      end
    end

    def request_uri
      self.class.site + self.class.path
    end

    def persisted?
      !new_record?
    end

    def new_record?
      id.nil?
    end
    alias new? new_record?

    protected

    def to_params
      attributes
    end

    def create_request(method = :post)
      Typhoid::RequestBuilder.new(self.class, request_uri, :body => to_params, :method => method)
    end

    def update_request(method = :put)
      uri = request_uri + self.id.to_s
      Typhoid::RequestBuilder.new(self.class, uri, :body => to_params, :method => method, :headers => {"Content-Type" => 'application/json'})
    end

    def delete_request(method = :delete)
      uri = request_uri + self.id.to_s
      Typhoid::RequestBuilder.new(self.class, uri, :method => method)
    end
  end
end
