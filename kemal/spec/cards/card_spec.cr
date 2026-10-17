require "spec"
require "http/client"
require "json"

describe "Card API" do
  it "lists cards" do
    response = HTTP::Client.get("http://localhost:3000/api/cards")
    response.status_code.should eq 200
  end

  it "searches cards" do
    response = HTTP::Client.get("http://localhost:3000/api/cards?q=test")
    response.status_code.should eq 200
  end

  it "creates a card" do
    body = {"public_id": "00000000-0000-0000-0000-000000000001", "name": "test", "card_type": "C", "rarity": "C", "mana_cost": 1, "mana_colors": "W", "attack": 1, "defense": 1, "loyalty": 1, "description": "test", "flavor_text": "test", "image_url": "https://example.com", "artist_name": "test", "legal_formats": "S", "is_banned": true, "is_restricted": true, "power_level": 1, "metadata": "{}", "total_copies_in_circulation": 1, "set_id": 1}.to_json
    response = HTTP::Client.post(
      "http://localhost:3000/api/cards",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    response.status_code.should eq 201
  end

  it "retrieves a card" do
    response = HTTP::Client.get("http://localhost:3000/api/cards/1")
    [200, 404].should contain response.status_code
  end

  it "updates a card" do
    body = {"flavor_text": "test"}.to_json
    response = HTTP::Client.patch(
      "http://localhost:3000/api/cards/1",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    [200, 404].should contain response.status_code
  end

end
