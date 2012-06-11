module NginHttp
	module Io

		def remote_resources(hydra = nil)
	    request_queue = RequestQueue.new(self, hydra)
	    yield request_queue if block_given?
	    
	    request_queue.run
	    
	    request_queue.requests.each do |req|
	    	parse_response req
	    end
	  end

	  private 

	  def parse_response(req)
	  	varname = "@" + req.name.to_s
	  	if req.response.success?
      	response_body = JSON.parse(req.response.body)
      	if response_body.is_a? Array
      		parse_array(varname, req, response_body)
      	else
      		parse_single_obj(varname, req, response_body)
      	end
      else
      	assign_request_error(varname, req)
      end
	  end

	  def parse_array(varname, req, content)
			req.target.instance_variable_set varname.to_sym, []
      content.each do |obj|
      	(req.target.instance_variable_get varname.to_sym) << req.klass.new(obj) 
      end
	  end

	  def parse_single_obj(varname, req, content)
	  	req.target.instance_variable_set(varname.to_sym, req.klass.new(content))
	  end

	   def assign_request_error(varname, req)
	  	obj = req.klass.new
	  	obj.resource_exception = Exception.new("Could not retrieve data from remote service") #TODO: more specific errors
	  	req.target.instance_variable_set(varname.to_sym, obj)
	  end
	end
end