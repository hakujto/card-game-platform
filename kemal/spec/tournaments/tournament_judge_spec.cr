require "spec"
require "http/client"
require "json"

describe "TournamentJudge API" do
  it "lists tournament_judges" do
    response = HTTP::Client.get("http://localhost:3000/api/tournament_judges")
    response.status_code.should eq 200
  end

  it "creates a tournament_judge" do
    body = {"role": "H", "tournament_id": 1, "player_id": 1}.to_json
    response = HTTP::Client.post(
      "http://localhost:3000/api/tournament_judges",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    response.status_code.should eq 201
  end

  it "retrieves a tournament_judge" do
    response = HTTP::Client.get("http://localhost:3000/api/tournament_judges/1")
    [200, 404].should contain response.status_code
  end

  it "deletes a tournament_judge" do
    response = HTTP::Client.delete("http://localhost:3000/api/tournament_judges/1")
    [204, 404].should contain response.status_code
  end

end
