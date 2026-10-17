require "spec"
require "http/client"
require "json"

describe "TournamentRound API" do
  it "lists tournament_rounds" do
    response = HTTP::Client.get("http://localhost:3000/api/tournament_rounds")
    response.status_code.should eq 200
  end

  it "creates a tournament_round" do
    body = {"round_number": 1, "status": "P", "startedAt": "2024-01-01T00:00:00Z", "endedAt": "2024-01-01T00:00:00Z", "time_limit_minutes": 1, "tournament_id": 1}.to_json
    response = HTTP::Client.post(
      "http://localhost:3000/api/tournament_rounds",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    response.status_code.should eq 201
  end

  it "retrieves a tournament_round" do
    response = HTTP::Client.get("http://localhost:3000/api/tournament_rounds/1")
    [200, 404].should contain response.status_code
  end

end
