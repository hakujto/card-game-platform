require "spec"
require "http/client"
require "json"

describe "Match API" do
  it "lists matches" do
    response = HTTP::Client.get("http://localhost:3000/api/matches")
    response.status_code.should eq 200
  end

  it "creates a match" do
    body = {"table_number": 1, "status": "P", "player1_wins": 1, "player2_wins": 1, "startedAt": "2024-01-01T00:00:00Z", "endedAt": "2024-01-01T00:00:00Z", "result_notes": "test", "round_id": 1, "player1_id": 1, "player2_id": 1}.to_json
    response = HTTP::Client.post(
      "http://localhost:3000/api/matches",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    response.status_code.should eq 201
  end

  it "retrieves a match" do
    response = HTTP::Client.get("http://localhost:3000/api/matches/1")
    [200, 404].should contain response.status_code
  end

end
