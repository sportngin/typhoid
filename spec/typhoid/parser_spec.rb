require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Typhoid::Parser do

  let(:parser) { Typhoid::Parser }
  let(:body) { JSON.generate(result: %w[a b c]) }

  it "should parse json" do
    parsed_response = parser.call(body)
    parsed_response.should == { "result" => ["a", "b", "c"] }
  end

end
