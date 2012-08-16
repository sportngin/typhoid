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
      if uri !~ Regexp.compile("^#{Regexp.escape(base_request_uri || "")}")
        uri = built_request_uri(uri)
      end
      Typhoid::RequestBuilder.new(self, uri, options)
    end

    def self.run(request)
      method = request.http_method
      parse(request.klass, (Typhoeus::Request.send method, request.request_uri, request.options))
    end

    def self.base_request_uri
      if site or path
        temp_site = site.gsub /\/$/, '' if site
        temp_path = path.gsub(/^\//, '').gsub /\/$/, '' if path
        [temp_site, temp_path].compact.join '/'
      else
        nil
      end
    end

    def self.built_request_uri(path_or_query = nil)
      if path_or_query =~ /^http:\/\//i
        path_or_query
      else
        path_or_query = path_or_query.gsub(/^\//, '') unless path_or_query.nil?
        [base_request_uri, path_or_query].compact.join '/'
      end
    end

    def initialize(params = {})
      load_values(params)
    end

    def save!(method = nil)
      response = Typhoeus::Request.send save_http_method(method), save_request.request_uri, save_request.options
      Typhoid::Resource.load_values(self, response)
    end

    def destroy!
      response = Typhoeus::Request.delete(delete_request.request_uri, delete_request.options)
      Typhoid::Resource.load_values(self, response)
    end

    def save_request
      (new_record?) ? create_request : update_request
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

    protected

    def new_record?
      id.nil?
    end

    def create_request(method = :post)
      Typhoid::RequestBuilder.new(self.class, request_uri, :params => attributes, :method => method)
    end

    def update_request(method = :put)
      uri = request_uri + self.id.to_s
      Typhoid::RequestBuilder.new(self.class, uri, :body => attributes.to_json, :method => method, :headers => {"Content-Type" => 'application/json'})
    end

    def delete_request(method = :delete)
      uri = request_uri + self.id.to_s
      Typhoid::RequestBuilder.new(self.class, uri, :method => method)
    end
  end
end
