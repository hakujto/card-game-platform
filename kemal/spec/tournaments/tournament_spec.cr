require "spec"
require "http/client"
require "json"

describe "Tournament API" do
  it "lists tournaments" do
    response = HTTP::Client.get("http://localhost:3000/api/tournaments")
    response.status_code.should eq 200
  end

  it "searches tournaments" do
    response = HTTP::Client.get("http://localhost:3000/api/tournaments?q=test")
    response.status_code.should eq 200
  end

  it "creates a tournament" do
    body = {"public_id": "00000000-0000-0000-0000-000000000001", "name": "test", "description": "test", "status": "D", "bracket_data": "{}", "format": "S", "tournament_type": "S", "max_players": 1, "entry_fee": 1.0, "prize_pool": 1.0, "startTime": "2024-01-01T00:00:00Z", "endTime": "2024-01-01T00:00:00Z", "is_online": true, "location": "test", "rules_text": "test", "season_id": 1, "organizer_id": 1}.to_json
    response = HTTP::Client.post(
      "http://localhost:3000/api/tournaments",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    response.status_code.should eq 201
  end

  it "retrieves a tournament" do
    response = HTTP::Client.get("http://localhost:3000/api/tournaments/1")
    [200, 404].should contain response.status_code
  end

  it "updates a tournament" do
    body = {"description": "test"}.to_json
    response = HTTP::Client.patch(
      "http://localhost:3000/api/tournaments/1",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    [200, 404].should contain response.status_code
  end

end
