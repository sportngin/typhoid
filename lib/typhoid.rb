require "typhoid/version"
require 'typhoid/uri'
require 'typhoid/parser'
require 'typhoid/builder'

module Typhoid
  TyphoeusCompatabilityError = Class.new StandardError

  def self.typhoeus
    @typhoeus ||= TyphoeusDescriptor.new
  end

  class TyphoeusDescriptor
    def version
      Typhoeus::VERSION
    end

    def matched_version
      version.to_s.match /(?<major>\d+)\.(?<minor>\d+)\.(?<bug>\d+)/
    end

    def major_version
      matched_version[:major].to_i
    end

    def minor_version
      matched_version[:minor].to_i
    end

    def bug_version
      matched_version[:bug].to_i
    end
  end
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
