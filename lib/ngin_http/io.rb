module NginHttp
	module Io

		def remote_resources(hydra = nil)
	    request_queue = RequestQueue.new(self, hydra)
	    yield request_queue if block_given?
	    
	    request_queue.run
	    
	    request_queue.requests.each do |req|
	    	parse_queued_response req
	    end
	  end

	  def fetch(request)
  		parse(request.klass, Typhoeus::Request.get(request.request_uri, request.options))
  	end


	  private 

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

	  def parse_queued_response(req)
	  	varname = "@" + req.name.to_s
	  	req.target.instance_variable_set varname.to_sym, parse(req.klass, req.response)
	  end

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

	  def assign_request_error(klass)
	  	obj = klass.new
	  	obj.resource_exception = Exception.new("Could not retrieve data from remote service") #TODO: more specific errors
	  	obj
	  end
	end
end