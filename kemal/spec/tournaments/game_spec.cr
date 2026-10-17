require "spec"
require "http/client"
require "json"

describe "Game API" do
  it "lists games" do
    response = HTTP::Client.get("http://localhost:3000/api/games")
    response.status_code.should eq 200
  end

  it "creates a game" do
    body = {"game_number": 1, "winner_side": "P", "complexity_score": 1.0, "turns_played": 1, "duration_seconds": 1, "ended_by": "N", "replay_url": "https://example.com", "match_id": 1, "winner_id": 1}.to_json
    response = HTTP::Client.post(
      "http://localhost:3000/api/games",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    response.status_code.should eq 201
  end

  it "retrieves a game" do
    response = HTTP::Client.get("http://localhost:3000/api/games/1")
    [200, 404].should contain response.status_code
  end

end
