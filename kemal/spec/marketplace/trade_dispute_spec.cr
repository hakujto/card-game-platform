require "spec"
require "http/client"
require "json"

describe "TradeDispute API" do
  it "lists trade_disputes" do
    response = HTTP::Client.get("http://localhost:3000/api/trade_disputes")
    response.status_code.should eq 200
  end

  it "creates a trade_dispute" do
    body = {"status": "O", "reason": "I", "description": "test", "resolution": "test", "openedAt": "2024-01-01T00:00:00Z", "resolvedAt": "2024-01-01T00:00:00Z", "transaction_id": 1, "opened_by_id": 1, "resolved_by_id": 1}.to_json
    response = HTTP::Client.post(
      "http://localhost:3000/api/trade_disputes",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    response.status_code.should eq 201
  end

  it "retrieves a trade_dispute" do
    response = HTTP::Client.get("http://localhost:3000/api/trade_disputes/1")
    [200, 404].should contain response.status_code
  end

end
