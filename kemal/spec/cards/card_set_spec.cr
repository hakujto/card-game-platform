require "spec"
require "http/client"
require "json"

describe "CardSet API" do
  it "lists card_sets" do
    response = HTTP::Client.get("http://localhost:3000/api/card_sets")
    response.status_code.should eq 200
  end

  it "searches card_sets" do
    response = HTTP::Client.get("http://localhost:3000/api/card_sets?q=test")
    response.status_code.should eq 200
  end

  it "creates a card_set" do
    body = {"name": "test", "code": "test", "release_date": "2024-01-01", "rotation_date": "2024-01-01", "set_type": "C", "total_cards": 1, "is_rotated": true, "description": "test", "logo_url": "https://example.com"}.to_json
    response = HTTP::Client.post(
      "http://localhost:3000/api/card_sets",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    response.status_code.should eq 201
  end

  it "retrieves a card_set" do
    response = HTTP::Client.get("http://localhost:3000/api/card_sets/1")
    [200, 404].should contain response.status_code
  end

  it "updates a card_set" do
    body = {"name": "test"}.to_json
    response = HTTP::Client.patch(
      "http://localhost:3000/api/card_sets/1",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    [200, 404].should contain response.status_code
  end

end
