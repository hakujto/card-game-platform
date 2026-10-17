require "spec"
require "http/client"
require "json"

describe "TournamentPrize API" do
  it "lists tournament_prizes" do
    response = HTTP::Client.get("http://localhost:3000/api/tournament_prizes")
    response.status_code.should eq 200
  end

  it "creates a tournament_prize" do
    body = {"placement_from": 1, "placement_to": 1, "prize_type": "C", "amount": 1.0, "description": "test", "packs_count": 1, "season_points": 1, "tournament_id": 1}.to_json
    response = HTTP::Client.post(
      "http://localhost:3000/api/tournament_prizes",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    response.status_code.should eq 201
  end

  it "retrieves a tournament_prize" do
    response = HTTP::Client.get("http://localhost:3000/api/tournament_prizes/1")
    [200, 404].should contain response.status_code
  end

  it "updates a tournament_prize" do
    body = {"placement_from": 1}.to_json
    response = HTTP::Client.patch(
      "http://localhost:3000/api/tournament_prizes/1",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    [200, 404].should contain response.status_code
  end

  it "deletes a tournament_prize" do
    response = HTTP::Client.delete("http://localhost:3000/api/tournament_prizes/1")
    [204, 404].should contain response.status_code
  end

end
