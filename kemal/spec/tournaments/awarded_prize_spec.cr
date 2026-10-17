require "spec"
require "http/client"
require "json"

describe "AwardedPrize API" do
  it "lists awarded_prizes" do
    response = HTTP::Client.get("http://localhost:3000/api/awarded_prizes")
    response.status_code.should eq 200
  end

  it "retrieves a awarded_prize" do
    response = HTTP::Client.get("http://localhost:3000/api/awarded_prizes/1")
    [200, 404].should contain response.status_code
  end

end
