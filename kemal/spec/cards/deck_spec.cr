require "spec"
require "http/client"
require "json"

describe "Deck API" do
  it "lists decks" do
    response = HTTP::Client.get("http://localhost:3000/api/decks")
    response.status_code.should eq 200
  end

  it "searches decks" do
    response = HTTP::Client.get("http://localhost:3000/api/decks?q=test")
    response.status_code.should eq 200
  end

  it "creates a deck" do
    body = {"name": "test", "description": "test", "format": "S", "is_public": true, "is_tournament_legal": true, "archetype": "A", "wins": 1, "losses": 1, "draws": 1, "player_id": 1}.to_json
    response = HTTP::Client.post(
      "http://localhost:3000/api/decks",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    response.status_code.should eq 201
  end

  it "retrieves a deck" do
    response = HTTP::Client.get("http://localhost:3000/api/decks/1")
    [200, 404].should contain response.status_code
  end

  it "updates a deck" do
    body = {"name": "test"}.to_json
    response = HTTP::Client.patch(
      "http://localhost:3000/api/decks/1",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    [200, 404].should contain response.status_code
  end

  it "deletes a deck" do
    response = HTTP::Client.delete("http://localhost:3000/api/decks/1")
    [204, 404].should contain response.status_code
  end

end
