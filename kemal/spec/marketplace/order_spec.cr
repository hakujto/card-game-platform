require "spec"
require "http/client"
require "json"

describe "Order API" do
  it "lists orders" do
    response = HTTP::Client.get("http://localhost:3000/api/orders")
    response.status_code.should eq 200
  end

  it "creates a order" do
    body = {"status": "P", "total": 1.0, "discount_applied": 1.0, "currency": "test", "payment_method": "C", "shipping_address": "test", "tracking_number": "test", "paidAt": "2024-01-01T00:00:00Z", "shippedAt": "2024-01-01T00:00:00Z", "player_id": 1, "coupon_id": 1}.to_json
    response = HTTP::Client.post(
      "http://localhost:3000/api/orders",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    response.status_code.should eq 201
  end

  it "retrieves a order" do
    response = HTTP::Client.get("http://localhost:3000/api/orders/1")
    [200, 404].should contain response.status_code
  end

end
