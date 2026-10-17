require "spec"
require "http/client"
require "json"

describe "Product API" do
  it "lists products" do
    response = HTTP::Client.get("http://localhost:3000/api/products")
    response.status_code.should eq 200
  end

  it "searches products" do
    response = HTTP::Client.get("http://localhost:3000/api/products?q=test")
    response.status_code.should eq 200
  end

  it "creates a product" do
    body = {"name": "test", "product_type": "S", "price": 1.0, "stock": 1, "active": true, "discount_percent": 1, "description": "test", "image_url": "https://example.com", "featured": true, "card_id": 1, "card_set_id": 1}.to_json
    response = HTTP::Client.post(
      "http://localhost:3000/api/products",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    response.status_code.should eq 201
  end

  it "retrieves a product" do
    response = HTTP::Client.get("http://localhost:3000/api/products/1")
    [200, 404].should contain response.status_code
  end

  it "updates a product" do
    body = {"description": "test"}.to_json
    response = HTTP::Client.patch(
      "http://localhost:3000/api/products/1",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    [200, 404].should contain response.status_code
  end

end
