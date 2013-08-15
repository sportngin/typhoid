require 'typhoeus'
module Typhoid
  class Request < TyphoeusDecorator
    decorate ::Typhoeus::Request

    ACCESSOR_OPTIONS = [
      :method,
      :params,
      :body,
      :headers,
      :cache_key_basis,
      :connect_timeout,
      :timeout,
      :user_agent,
      :response,
      :cache_timeout,
      :follow_location,
      :max_redirects,
      :proxy,
      :proxy_username,
      :proxy_password,
      :disable_ssl_peer_verification,
      :disable_ssl_host_verification,
      :interface,
      :ssl_cert,
      :ssl_cert_type,
      :ssl_key,
      :ssl_key_type,
      :ssl_key_password,
      :ssl_cacert,
      :ssl_capath,
      :ssl_version,
      :verbose,
      :username,
      :password,
      :auth_method,
      :proxy_auth_method,
      :proxy_type
    ]

    def run
      if Typhoid.typhoeus.major_version == 0
        if Typhoid.typhoeus.minor_version >= 6
          response = source.run
        else
          response = Typhoeus::Request.send(method, url, options)
        end
      end
      Typhoid::Response.new response
    end

    def response
      compat [:handled_response, :response]
    end

    # Need to force override, because Object#method
    def method
      options[:method] || :get
    end

    def options
      @options ||= if source.respond_to?(:options)
                     source.options
                   else
                     ACCESSOR_OPTIONS.reduce({}) do |hash, key|
                       hash[key] = source.send(key) if source.respond_to?(:key) && source.method(key).arity < 1
                       hash
                     end
                   end
    end
  end
end
