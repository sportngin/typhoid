require 'cgi'

module NginHttp

	module Resource
	
		attr_accessor :resource_exception

		def initialize(params = {})
			self.class.auto_init_fields.each do |f|
				self.send "#{f}=", params[f.to_s]	
			end
		end

		def self.included(base)
			base.extend ClassMethods
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
		end

	end
end