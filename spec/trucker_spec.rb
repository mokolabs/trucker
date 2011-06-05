require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class LegacyMuppet
  class << self
    def limit(number)
      self
    end
    def offset(number)
      self
    end
    def all
      self
    end
  end
end

describe "Trucker builds ActiveRecord queries in Rails 3 syntax" do
  it "handles limits" do
    ENV['limit'] = "20"
    ENV['offset'] = nil
    Trucker.number_of_records.should == ".limit(20)"
    Trucker.construct_query("muppets").should == "LegacyMuppet.limit(20)"
  end
  it "handles ordering" do
    ENV['offset'] = "20"
    ENV['limit'] = nil
    Trucker.offset_for_records.should == ".offset(20)"
    Trucker.construct_query("muppets").should == "LegacyMuppet.offset(20)"
  end
  it "handles an unmodified .all()" do
    ENV['offset'] = nil
    ENV['limit'] = nil
    Trucker.construct_query("muppets").should == "LegacyMuppet.all"
  end
end

