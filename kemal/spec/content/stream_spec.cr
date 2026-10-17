require "spec"
require "http/client"
require "json"

describe "Stream API" do
  it "lists streams" do
    response = HTTP::Client.get("http://localhost:3000/api/streams")
    response.status_code.should eq 200
  end

  it "searches streams" do
    response = HTTP::Client.get("http://localhost:3000/api/streams?q=test")
    response.status_code.should eq 200
  end

  it "creates a stream" do
    body = {"title": "test", "stream_url": "https://example.com", "status": "S", "platform": "T", "language": "E", "is_official": true, "viewer_count_peak": 1, "scheduledStart": "2024-01-01T00:00:00Z", "actualStart": "2024-01-01T00:00:00Z", "endedAt": "2024-01-01T00:00:00Z", "vod_url": "https://example.com", "tournament_id": 1, "streamer_id": 1}.to_json
    response = HTTP::Client.post(
      "http://localhost:3000/api/streams",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    response.status_code.should eq 201
  end

  it "retrieves a stream" do
    response = HTTP::Client.get("http://localhost:3000/api/streams/1")
    [200, 404].should contain response.status_code
  end

  it "updates a stream" do
    body = {"title": "test"}.to_json
    response = HTTP::Client.patch(
      "http://localhost:3000/api/streams/1",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    [200, 404].should contain response.status_code
  end

end
