require "spec"
require "http/client"
require "json"

describe "DraftPick API" do
  it "lists draft_picks" do
    response = HTTP::Client.get("http://localhost:3000/api/draft_picks")
    response.status_code.should eq 200
  end

  it "retrieves a draft_pick" do
    response = HTTP::Client.get("http://localhost:3000/api/draft_picks/1")
    [200, 404].should contain response.status_code
  end

end
