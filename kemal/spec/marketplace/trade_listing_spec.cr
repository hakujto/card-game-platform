require "spec"
require "http/client"
require "json"

describe "TradeListing API" do
  it "lists trade_listings" do
    response = HTTP::Client.get("http://localhost:3000/api/trade_listings")
    response.status_code.should eq 200
  end

  it "searches trade_listings" do
    response = HTTP::Client.get("http://localhost:3000/api/trade_listings?q=test")
    response.status_code.should eq 200
  end

  it "creates a trade_listing" do
    body = {"public_id": "00000000-0000-0000-0000-000000000001", "status": "A", "listing_type": "F", "asking_price": 1.0, "auction_start_price": 1.0, "auction_current_bid": 1.0, "auctionEndTime": "2024-01-01T00:00:00Z", "foil": true, "condition": "M", "quantity": 1, "description": "test", "expiresAt": "2024-01-01T00:00:00Z", "seller_id": 1, "card_id": 1}.to_json
    response = HTTP::Client.post(
      "http://localhost:3000/api/trade_listings",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    response.status_code.should eq 201
  end

  it "retrieves a trade_listing" do
    response = HTTP::Client.get("http://localhost:3000/api/trade_listings/1")
    [200, 404].should contain response.status_code
  end

  it "updates a trade_listing" do
    body = {"public_id": "00000000-0000-0000-0000-000000000001"}.to_json
    response = HTTP::Client.patch(
      "http://localhost:3000/api/trade_listings/1",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    [200, 404].should contain response.status_code
  end

end
