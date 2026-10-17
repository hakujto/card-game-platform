require "spec"
require "http/client"
require "json"

describe "Season API" do
  it "lists seasons" do
    response = HTTP::Client.get("http://localhost:3000/api/seasons")
    response.status_code.should eq 200
  end

  it "searches seasons" do
    response = HTTP::Client.get("http://localhost:3000/api/seasons?q=test")
    response.status_code.should eq 200
  end

  it "creates a season" do
    body = {"name": "test", "start_date": "2024-01-01", "end_date": "2024-01-01", "format": "S", "is_active": true, "reward_description": "test"}.to_json
    response = HTTP::Client.post(
      "http://localhost:3000/api/seasons",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    response.status_code.should eq 201
  end

  it "retrieves a season" do
    response = HTTP::Client.get("http://localhost:3000/api/seasons/1")
    [200, 404].should contain response.status_code
  end

  it "updates a season" do
    body = {"name": "test"}.to_json
    response = HTTP::Client.patch(
      "http://localhost:3000/api/seasons/1",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    [200, 404].should contain response.status_code
  end

end
