require 'spec_helper'

module Typhoid
  describe Parser do
    let(:example_json) { <<-JSON
      {
          "metadata": {
              "current_user": {
                  "first_name": "Jon",
                  "id": 1,
                  "last_name": "Gilmore",
                  "uri": "http://user-service.dev/users/1",
                  "user_name": "admin"
              }
          },
          "result": {
              "first_name": "Jon",
              "id": 15,
              "last_name": "Phenow",
              "type": "orphan",
              "uri": "http://user-service.dev/personas/15",
              "user": null
          }
      }
    JSON
    }

    let(:example_array) { <<-JSON
      [{"metadata": null }, {"metadata": null }]
    JSON
    }

    describe "class" do
      subject { Parser }

      describe "call" do
        subject { Parser.call(example_json) }

        it { should be_a Hash }
        it "has an expected element" do
          subject["result"]["first_name"].should == "Jon"
        end
      end
    end

    describe "instance" do
      subject { Parser.new example_json }
      describe "parse" do
        it "looks like a hash" do
          subject.parse.should be_a Hash
        end

        it "has an expected element" do
          subject.parse["result"]["type"].should == "orphan"
        end
      end

      describe "singular?" do
        describe "with hash" do
          its(:singular?) { should be_true }
        end

        describe "with array return" do
          let(:example_json) { example_array }
          its(:singular?) { should be_false }
        end
      end

      describe "array?" do
        describe "with hash" do
          its(:array?) { should be_false }
        end

        describe "with array return" do
          let(:example_json) { example_array }
          its(:array?) { should be_true }
        end
      end
    end
  end
end
