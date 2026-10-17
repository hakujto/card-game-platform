require "spec"
require "http/client"
require "json"

describe "DeckCard API" do
  it "lists deck_cards" do
    response = HTTP::Client.get("http://localhost:3000/api/deck_cards")
    response.status_code.should eq 200
  end

  it "creates a deck_card" do
    body = {"quantity": 1, "is_commander": true, "deck_id": 1, "card_id": 1}.to_json
    response = HTTP::Client.post(
      "http://localhost:3000/api/deck_cards",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    response.status_code.should eq 201
  end

  it "retrieves a deck_card" do
    response = HTTP::Client.get("http://localhost:3000/api/deck_cards/1")
    [200, 404].should contain response.status_code
  end

  it "updates a deck_card" do
    body = {"quantity": 1}.to_json
    response = HTTP::Client.patch(
      "http://localhost:3000/api/deck_cards/1",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    [200, 404].should contain response.status_code
  end

  it "deletes a deck_card" do
    response = HTTP::Client.delete("http://localhost:3000/api/deck_cards/1")
    [204, 404].should contain response.status_code
  end

end
