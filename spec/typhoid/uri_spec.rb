require 'spec_helper'
module Typhoid
  describe "Uri" do
    subject { Uri.new *uris }
    let(:uris) { ["http://localhost/", "users"] }

    its(:to_s) { should == "http://localhost/users" }
    it "sets base" do
      subject.base.to_s.should == "http://localhost"
    end

    it "sets path" do
      subject.paths.should == ["users"]
    end

    it "appends paths" do
      subject.join("/","/a/","b","/c","d/").should == "http://localhost/users/a/b/c/d"
    end

    it "when joining it doesn't change itself" do
      expect {
        subject.join("/","/a/","b","/c","d/").should == "http://localhost/users/a/b/c/d"
      }.
      to_not change { subject.to_s }
    end
  end
end
