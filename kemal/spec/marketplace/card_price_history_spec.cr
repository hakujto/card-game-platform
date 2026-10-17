require "spec"
require "http/client"
require "json"

describe "CardPriceHistory API" do
  it "lists card_price_histories" do
    response = HTTP::Client.get("http://localhost:3000/api/card_price_histories")
    response.status_code.should eq 200
  end

  it "retrieves a card_price_history" do
    response = HTTP::Client.get("http://localhost:3000/api/card_price_histories/1")
    [200, 404].should contain response.status_code
  end

end
