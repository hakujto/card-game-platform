require "spec"
require "http/client"
require "json"

describe "OrderItem API" do
  it "lists order_items" do
    response = HTTP::Client.get("http://localhost:3000/api/order_items")
    response.status_code.should eq 200
  end

  it "creates a order_item" do
    body = {"quantity": 1, "price_at_purchase": 1.0, "foil": true, "order_id": 1, "product_id": 1}.to_json
    response = HTTP::Client.post(
      "http://localhost:3000/api/order_items",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    response.status_code.should eq 201
  end

  it "retrieves a order_item" do
    response = HTTP::Client.get("http://localhost:3000/api/order_items/1")
    [200, 404].should contain response.status_code
  end

  it "deletes a order_item" do
    response = HTTP::Client.delete("http://localhost:3000/api/order_items/1")
    [204, 404].should contain response.status_code
  end

end
