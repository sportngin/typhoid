require 'spec_helper'
module Typhoid
  describe Builder do
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
    let(:klass) { Resource }
    let(:response) { double body: mocked_body, success?: mocked_success }
    let(:mocked_body) { example_json }
    let(:mocked_success) { true }
    describe "class" do
      subject { Builder }
      describe "call" do
        subject { Builder.call klass, response }
        it { should be_a Resource }
        its(:attributes) { should have_key "metadata" }
        its(:attributes) { should have_key "result" }
      end
    end

    describe "instance" do
      subject { Builder.new klass, response }
      describe "successful" do
        describe "singular" do
          it "calls expected building methods" do
            klass.any_instance.should_receive(:after_build).once
            subject.build.should be_a Resource
          end
        end

        describe "array" do
          let(:mocked_body) { example_array }
          it "calls expected building methods" do
            subject.build.should be_an Array
          end
        end
      end

      describe "unsuccessful" do
        let(:mocked_success) { false }
        subject { Builder.new(klass, response).build }
        describe "singular" do
          it { should be_a Resource }
          its(:resource_exception) { should_not be_nil }
          its(:attributes) { should have_key "metadata" }
        end

        describe "array" do
          let(:mocked_body) { example_array }
          subject { Builder.new(klass, response).build.first }

          it { should be_a Resource }
          its(:resource_exception) { should_not be_nil }
          its(:attributes) { should have_key "metadata" }
        end
      end
    end
  end
end
