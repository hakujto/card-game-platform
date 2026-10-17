require "spec"
require "http/client"
require "json"

describe "PlayerCollection API" do
  it "lists player_collections" do
    response = HTTP::Client.get("http://localhost:3000/api/player_collections")
    response.status_code.should eq 200
  end

  it "creates a player_collection" do
    body = {"quantity": 1, "foil": true, "condition": "M", "acquiredAt": "2024-01-01T00:00:00Z", "acquired_via": "P", "player_id": 1, "card_id": 1}.to_json
    response = HTTP::Client.post(
      "http://localhost:3000/api/player_collections",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    response.status_code.should eq 201
  end

  it "retrieves a player_collection" do
    response = HTTP::Client.get("http://localhost:3000/api/player_collections/1")
    [200, 404].should contain response.status_code
  end

  it "updates a player_collection" do
    body = {"quantity": 1}.to_json
    response = HTTP::Client.patch(
      "http://localhost:3000/api/player_collections/1",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    [200, 404].should contain response.status_code
  end

  it "deletes a player_collection" do
    response = HTTP::Client.delete("http://localhost:3000/api/player_collections/1")
    [204, 404].should contain response.status_code
  end

end
