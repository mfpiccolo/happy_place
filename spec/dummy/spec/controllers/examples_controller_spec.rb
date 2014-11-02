require "spec_helper"

describe ExamplesController do
  describe "#js" do
    it "should be defined" do
      ExamplesController.new.respond_to?(:js).should == true
    end
  end
end
