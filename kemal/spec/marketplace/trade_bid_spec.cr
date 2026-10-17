require "spec"
require "http/client"
require "json"

describe "TradeBid API" do
  it "lists trade_bids" do
    response = HTTP::Client.get("http://localhost:3000/api/trade_bids")
    response.status_code.should eq 200
  end

  it "creates a trade_bid" do
    body = {"amount": 1.0, "placedAt": "2024-01-01T00:00:00Z", "is_winning": true, "listing_id": 1, "bidder_id": 1}.to_json
    response = HTTP::Client.post(
      "http://localhost:3000/api/trade_bids",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    response.status_code.should eq 201
  end

  it "retrieves a trade_bid" do
    response = HTTP::Client.get("http://localhost:3000/api/trade_bids/1")
    [200, 404].should contain response.status_code
  end

end
