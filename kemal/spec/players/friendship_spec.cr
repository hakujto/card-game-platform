require "spec"
require "http/client"
require "json"

describe "Friendship API" do
  it "lists friendships" do
    response = HTTP::Client.get("http://localhost:3000/api/friendships")
    response.status_code.should eq 200
  end

  it "creates a friendship" do
    body = {"status": "P", "requester_id": 1, "receiver_id": 1}.to_json
    response = HTTP::Client.post(
      "http://localhost:3000/api/friendships",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    response.status_code.should eq 201
  end

  it "retrieves a friendship" do
    response = HTTP::Client.get("http://localhost:3000/api/friendships/1")
    [200, 404].should contain response.status_code
  end

  it "deletes a friendship" do
    response = HTTP::Client.delete("http://localhost:3000/api/friendships/1")
    [204, 404].should contain response.status_code
  end

end
