require 'cgi'

module NginHttp

	class Resource

		include NginHttp::Io

	
		attr_accessor :resource_exception

		def initialize(params = {})
			load_values(params)
		end

		def save!
  		response = Typhoeus::Request.send save_http_method, save_request.request_uri, save_request.options
  		NginHttp::Resource.load_values(self, response)
	  end

	  def destroy!
	   	#parse(request.klass, Typhoeus::Request.delete(request.request_uri, request.options))
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

		def load_values(params)
			self.class.auto_init_fields.each do |f|
				self.send "#{f}=", params[f.to_s]	
			end
		end



		protected

		def new_record?
			id.nil?
		end

		def create_request(method = :post)
			NginHttp::RequestBuilder.new(self.class, request_uri, :params => field_values_as_hash, :method => method)
		end

		def update_request(method = :put)
			NginHttp::RequestBuilder.new(self.class, request_uri, :params => field_values_as_hash, :method => method)
		end

		def field_values_as_hash
			params = {}
			self.class.auto_init_fields.each do |f|
				params[f.to_s] = self.send "#{f}"
			end
		end


		public 

		class << self

			def field(field_name)
				attr_accessor field_name.to_sym
				@auto_init_fields ||= []
				@auto_init_fields << field_name.to_sym
			end

			def auto_init_fields
				@auto_init_fields || []
			end

			def build_request(uri, options = {})
				NginHttp::RequestBuilder.new(self, uri, options)
			end

	  	def fetch(request)
  			parse(request.klass, Typhoeus::Request.get(request.request_uri, request.options))
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

	  	def parse(klass, response)
				if response.success?
	    		response_body = JSON.parse(response.body)
	    		if response_body.is_a? Array
	    			parse_array(klass, response_body)
	    		else

	    			parse_single_obj(klass, response_body)
	    		end
	    	else
	    		assign_request_error(klass)
	    	end
			end

			def load_values(obj, response)
		  	if response.success?
		  		response_body = JSON.parse(response.body)
		  		obj.load_values(response_body)
		  	else
		  		assign_request_error(obj.class, obj)
		  	end
		  end

	  	private


		  def parse_array(klass, content)
		  	values = []
	      content.each do |obj|
	      	values << klass.new(obj) 
	      end
	      values
		  end



		  def parse_single_obj(klass, content)
		  	klass.new(content)
		  end

		  def assign_request_error(klass, obj = nil)
		  	obj ||= klass.new
		  	obj.resource_exception = Exception.new("Could not retrieve data from remote service") #TODO: more specific errors
		  	obj
		  end

	  	
		end

		

	end
end