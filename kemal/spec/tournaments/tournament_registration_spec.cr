require "spec"
require "http/client"
require "json"

describe "TournamentRegistration API" do
  it "lists tournament_registrations" do
    response = HTTP::Client.get("http://localhost:3000/api/tournament_registrations")
    response.status_code.should eq 200
  end

  it "creates a tournament_registration" do
    body = {"status": "R", "seed": 1, "final_standing": 1, "points_earned": 1, "registeredAt": "2024-01-01T00:00:00Z", "tournament_id": 1, "player_id": 1, "deck_id": 1}.to_json
    response = HTTP::Client.post(
      "http://localhost:3000/api/tournament_registrations",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    response.status_code.should eq 201
  end

  it "retrieves a tournament_registration" do
    response = HTTP::Client.get("http://localhost:3000/api/tournament_registrations/1")
    [200, 404].should contain response.status_code
  end

end
