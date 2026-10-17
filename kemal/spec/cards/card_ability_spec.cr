require "spec"
require "http/client"
require "json"

describe "CardAbility API" do
  it "lists card_abilities" do
    response = HTTP::Client.get("http://localhost:3000/api/card_abilities")
    response.status_code.should eq 200
  end

  it "searches card_abilities" do
    response = HTTP::Client.get("http://localhost:3000/api/card_abilities?q=test")
    response.status_code.should eq 200
  end

  it "creates a card_ability" do
    body = {"ability_type": "K", "keyword": "test", "ability_text": "test", "timing": "A", "card_id": 1}.to_json
    response = HTTP::Client.post(
      "http://localhost:3000/api/card_abilities",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    response.status_code.should eq 201
  end

  it "retrieves a card_ability" do
    response = HTTP::Client.get("http://localhost:3000/api/card_abilities/1")
    [200, 404].should contain response.status_code
  end

  it "updates a card_ability" do
    body = {"ability_type": "K"}.to_json
    response = HTTP::Client.patch(
      "http://localhost:3000/api/card_abilities/1",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    [200, 404].should contain response.status_code
  end

  it "deletes a card_ability" do
    response = HTTP::Client.delete("http://localhost:3000/api/card_abilities/1")
    [204, 404].should contain response.status_code
  end

end
