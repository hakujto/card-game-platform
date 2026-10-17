require "spec"
require "http/client"
require "json"

describe "DeckTag API" do
  it "lists deck_tags" do
    response = HTTP::Client.get("http://localhost:3000/api/deck_tags")
    response.status_code.should eq 200
  end

  it "searches deck_tags" do
    response = HTTP::Client.get("http://localhost:3000/api/deck_tags?q=test")
    response.status_code.should eq 200
  end

  it "creates a deck_tag" do
    body = {"name": "test", "slug": "test", "color": "test"}.to_json
    response = HTTP::Client.post(
      "http://localhost:3000/api/deck_tags",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    response.status_code.should eq 201
  end

  it "retrieves a deck_tag" do
    response = HTTP::Client.get("http://localhost:3000/api/deck_tags/1")
    [200, 404].should contain response.status_code
  end

  it "updates a deck_tag" do
    body = {"name": "test"}.to_json
    response = HTTP::Client.patch(
      "http://localhost:3000/api/deck_tags/1",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    [200, 404].should contain response.status_code
  end

  it "deletes a deck_tag" do
    response = HTTP::Client.delete("http://localhost:3000/api/deck_tags/1")
    [204, 404].should contain response.status_code
  end

end
