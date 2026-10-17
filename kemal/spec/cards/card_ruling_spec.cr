require "spec"
require "http/client"
require "json"

describe "CardRuling API" do
  it "lists card_rulings" do
    response = HTTP::Client.get("http://localhost:3000/api/card_rulings")
    response.status_code.should eq 200
  end

  it "creates a card_ruling" do
    body = {"ruling_text": "test", "published_at": "2024-01-01", "source": "test", "card_id": 1}.to_json
    response = HTTP::Client.post(
      "http://localhost:3000/api/card_rulings",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    response.status_code.should eq 201
  end

  it "retrieves a card_ruling" do
    response = HTTP::Client.get("http://localhost:3000/api/card_rulings/1")
    [200, 404].should contain response.status_code
  end

  it "deletes a card_ruling" do
    response = HTTP::Client.delete("http://localhost:3000/api/card_rulings/1")
    [204, 404].should contain response.status_code
  end

end
