require "spec"
require "http/client"
require "json"

describe "Coupon API" do
  it "lists coupons" do
    response = HTTP::Client.get("http://localhost:3000/api/coupons")
    response.status_code.should eq 200
  end

  it "searches coupons" do
    response = HTTP::Client.get("http://localhost:3000/api/coupons?q=test")
    response.status_code.should eq 200
  end

  it "creates a coupon" do
    body = {"code": "test", "discount_type": "P", "discount_value": 1.0, "min_order_value": 1.0, "valid_from": "2024-01-01T00:00:00Z", "valid_until": "2024-01-01T00:00:00Z", "is_active": true}.to_json
    response = HTTP::Client.post(
      "http://localhost:3000/api/coupons",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    response.status_code.should eq 201
  end

  it "retrieves a coupon" do
    response = HTTP::Client.get("http://localhost:3000/api/coupons/1")
    [200, 404].should contain response.status_code
  end

  it "updates a coupon" do
    body = {"code": "test"}.to_json
    response = HTTP::Client.patch(
      "http://localhost:3000/api/coupons/1",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    [200, 404].should contain response.status_code
  end

end
