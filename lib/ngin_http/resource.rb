require 'cgi'

module NginHttp

	module Resource

		include NginHttp::Io

	
		attr_accessor :resource_exception

		def initialize(params = {})
			load_values(params)
		end

		def save!
			if new_record?
				NginHttp::Io.save(self, save_http_method, save_request)
			end
		end


		def self.included(base)
			base.extend ClassMethods
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

		def create_request
			params = {}
			self.class.auto_init_fields.each do |f|
				params[f.to_s] = self.send "#{f}"
			end
			NginHttp::RequestBuilder.new(self.class, request_uri, :params => params, :method => save_http_method)
		end

		def update_request

		end



		module ClassMethods

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
	  		NginHttp::Io.fetch(request)
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