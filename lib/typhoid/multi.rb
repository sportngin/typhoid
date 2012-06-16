module Typhoid
	module Multi

		def remote_resources(hydra = nil)
	    request_queue = RequestQueue.new(self, hydra)
	    yield request_queue if block_given?
	    
	    request_queue.run
	    
	    request_queue.requests.each do |req|
	    	parse_queued_response req
	    end
	  end

	  protected

	  def parse_queued_response(req)
		  	varname = "@" + req.name.to_s
		  	req.target.instance_variable_set varname.to_sym, Typhoid::Resource.parse(req.klass, req.response)
		  end

	end
end