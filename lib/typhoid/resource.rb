require 'cgi'

module Typhoid

	class Resource

		include Typhoid::Multi
		include Typhoid::Attributes

	
		attr_accessor :resource_exception

		def initialize(params = {})
			load_values(params)
		end

		def save!
  		response = Typhoeus::Request.send save_http_method, save_request.request_uri, save_request.options
  		Typhoid::Resource.load_values(self, response)
	  end

	  def destroy!
	  	response = Typhoeus::Request.delete(delete_request.request_uri, delete_request.options)
	   	Typhoid::Resource.load_values(self, response)
	 	end

		def save_request
			(new_record?) ? create_request : update_request
		end

		def save_http_method
			(new_record?) ? :post : :put
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
			Typhoid::RequestBuilder.new(self.class, uri, :body => attributes.to_json,  :method => method, :headers => {"Content-Type" => 'application/json'})
		end

		def delete_request(method = :delete)
			uri = request_uri + self.id.to_s
			Typhoid::RequestBuilder.new(self.class, uri, :method => method)
		end

		public 

		class << self

			def build_request(uri, options = {})
				Typhoid::RequestBuilder.new(self, uri, options)
			end

	  	def run(request)
	  		method = request.http_method
  			parse(request.klass, (Typhoeus::Request.send method, request.request_uri, request.options))
  		end

	  	def site=(value)
	  		@@site = value
	  	end

	  	def site
	  		@@site
	  	end

	  	def path=(value)
	  		@@path = value
	  	end

	  	def path
	  		@@path
	  	end
	  	
		end

		

	end
end