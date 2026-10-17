require "spec"
require "http/client"
require "json"

describe "DraftSession API" do
  it "lists draft_sessions" do
    response = HTTP::Client.get("http://localhost:3000/api/draft_sessions")
    response.status_code.should eq 200
  end

  it "creates a draft_session" do
    body = {"status": "W", "draft_type": "B", "pack_contents": "{}", "seats": 1, "time_per_pick_seconds": 1, "completedAt": "2024-01-01T00:00:00Z", "card_set_id": 1}.to_json
    response = HTTP::Client.post(
      "http://localhost:3000/api/draft_sessions",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    response.status_code.should eq 201
  end

  it "retrieves a draft_session" do
    response = HTTP::Client.get("http://localhost:3000/api/draft_sessions/1")
    [200, 404].should contain response.status_code
  end

end
