require "spec"
require "http/client"
require "json"

describe "Player API" do
  it "lists players" do
    response = HTTP::Client.get("http://localhost:3000/api/players")
    response.status_code.should eq 200
  end

  it "searches players" do
    response = HTTP::Client.get("http://localhost:3000/api/players?q=test")
    response.status_code.should eq 200
  end

  it "creates a player" do
    body = {"public_id": "00000000-0000-0000-0000-000000000001", "display_name": "test", "rank": "B", "rating": 1, "peak_rating": 1, "bio": "test", "country_code": "test", "avatar_url": "https://example.com", "preferred_format": "S", "contact_email": "test@example.com", "win_rate_cached": 1.0, "is_verified": true, "lastActiveAt": "2024-01-01T00:00:00Z", "user_id": 1}.to_json
    response = HTTP::Client.post(
      "http://localhost:3000/api/players",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    response.status_code.should eq 201
  end

  it "retrieves a player" do
    response = HTTP::Client.get("http://localhost:3000/api/players/1")
    [200, 404].should contain response.status_code
  end

  it "updates a player" do
    body = {"bio": "test"}.to_json
    response = HTTP::Client.patch(
      "http://localhost:3000/api/players/1",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    [200, 404].should contain response.status_code
  end

end
