require "typhoid/version"
require 'typhoid/uri'
require 'typhoid/parser'
require 'typhoid/builder'

module Typhoid
  TyphoeusCompatabilityError = Class.new StandardError
end

require 'typhoid/typhoeus_decorator'
require 'typhoid/request'
require 'typhoid/response'
require "typhoid/request_queue"
require "typhoid/queued_request"
require "typhoid/multi"
require 'typhoid/attributes'
require 'typhoid/resource'
require 'typhoid/request_builder'
