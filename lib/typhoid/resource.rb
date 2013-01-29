require 'cgi'
require 'typhoid/uri'

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

    def self.uri_join(*paths)
      Uri.new(*paths).to_s
    end

    # Get this request URI based on site and path, can attach
    # more paths
    def self.request_uri(*more_paths)
      uri_join site, path, *more_paths
    end

    def initialize(params = {})
      load_values(params)
    end

    def success?
      !resource_exception
    end

    def save!(method = nil)
      save method
      raise resource_exception unless success?
    end

    def destroy!
      destroy
      raise resource_exception unless success?
    end

    def save(method = nil)
      request_and_load do
        Typhoeus::Request.send save_http_method(method), save_request.request_uri, save_request.options
      end
    end

    def destroy
      request_and_load do
        Typhoeus::Request.delete(delete_request.request_uri, delete_request.options)
      end
    end

    def save_request
      (new_record?) ? create_request : update_request
    end

    def save_http_method(method = nil)
      return method if method
      (new_record?) ? :post : :put
    end

    # Request URI is either in the object we retrieveed initially, built from
    # site + path + id, or fail to the regular class#request_uri
    #
    # Also, check that the server we're speaking to isn't hypermedia inclined so
    # look at our attributes for a URI
    def request_uri
      attributes["uri"] || (new_record? ? self.class.request_uri : self.class.request_uri(id))
    end

    def request_and_load(&block)
      self.resource_exception = nil
      response = yield
      self.class.load_values(self, response)
      success?
    end

    def persisted?
      !new_record?
    end

    def new_record?
      id.to_s.length < 1
    end
    alias new? new_record?

    protected

    def to_params
      attributes
    end

    def create_request(method = :post)
      Typhoid::RequestBuilder.new(self.class, request_uri, :body => to_params.to_json, :method => method, :headers => {"Content-Type" => 'application/json'})
    end

    def update_request(method = :put)
      Typhoid::RequestBuilder.new(self.class, request_uri, :body => to_params.to_json, :method => method, :headers => {"Content-Type" => 'application/json'})
    end

    def delete_request(method = :delete)
      Typhoid::RequestBuilder.new(self.class, request_uri, :method => method)
    end
  end
end
