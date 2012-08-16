require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Typhoid::RequestBuilder do
  context "a request builder object" do
    it "should provide an http method by default" do
      req = Typhoid::RequestBuilder.new(Game, 'http://localhost/')
      req.http_method.should eql :get
    end

    it "should set http method from options" do
      req = Typhoid::RequestBuilder.new(Game, 'http://localhost', :method => :post)
      req.http_method.should eql :post
    end
  end
end
