require "spec"
require "http/client"
require "json"

describe "Achievement API" do
  it "lists achievements" do
    response = HTTP::Client.get("http://localhost:3000/api/achievements")
    response.status_code.should eq 200
  end

  it "searches achievements" do
    response = HTTP::Client.get("http://localhost:3000/api/achievements?q=test")
    response.status_code.should eq 200
  end

  it "creates a achievement" do
    body = {"name": "test", "description": "test", "icon_url": "https://example.com", "points": 1, "rarity": "C", "is_hidden": true}.to_json
    response = HTTP::Client.post(
      "http://localhost:3000/api/achievements",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    response.status_code.should eq 201
  end

  it "retrieves a achievement" do
    response = HTTP::Client.get("http://localhost:3000/api/achievements/1")
    [200, 404].should contain response.status_code
  end

  it "updates a achievement" do
    body = {"name": "test"}.to_json
    response = HTTP::Client.patch(
      "http://localhost:3000/api/achievements/1",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    [200, 404].should contain response.status_code
  end

end
