require "spec"
require "http/client"
require "json"

describe "DraftParticipant API" do
  it "lists draft_participants" do
    response = HTTP::Client.get("http://localhost:3000/api/draft_participants")
    response.status_code.should eq 200
  end

  it "creates a draft_participant" do
    body = {"seat_number": 1, "joinedAt": "2024-01-01T00:00:00Z", "session_id": 1, "player_id": 1}.to_json
    response = HTTP::Client.post(
      "http://localhost:3000/api/draft_participants",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    response.status_code.should eq 201
  end

  it "retrieves a draft_participant" do
    response = HTTP::Client.get("http://localhost:3000/api/draft_participants/1")
    [200, 404].should contain response.status_code
  end

end
