require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Trucker builds ActiveRecord queries in Rails 3 syntax" do
  before(:each) do
    ENV['offset'] = nil
    ENV['limit'] = nil
    ENV['where'] = nil
  end
  it "handles limits" do
    ENV['limit'] = "20"
    Trucker.limit.should == ".limit(20)"
    Trucker.construct_query("muppets").should == "LegacyMuppet.limit(20)"
  end
  it "handles ordering" do
    ENV['offset'] = "20"
    Trucker.offset.should == ".offset(20)"
    Trucker.construct_query("muppets").should == "LegacyMuppet.offset(20)"
  end
  it "handles an unmodified .all()" do
    Trucker.construct_query("muppets").should == "LegacyMuppet.all"
  end
  it "handles where()" do
    ENV['where'] = ":username => 'fred'"
    Trucker.construct_query("muppets").should == "LegacyMuppet.where(:username => 'fred')"
  end
end

describe "Trucker can handle fucking underscores" do
  Trucker.base("muppets").should == "LegacyMuppet"
  Trucker.base("muppet_balls").should == "LegacyMuppetBall"
end

