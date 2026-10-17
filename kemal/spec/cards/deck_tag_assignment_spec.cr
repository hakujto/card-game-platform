require "spec"
require "http/client"
require "json"

describe "DeckTagAssignment API" do
  it "lists deck_tag_assignments" do
    response = HTTP::Client.get("http://localhost:3000/api/deck_tag_assignments")
    response.status_code.should eq 200
  end

  it "creates a deck_tag_assignment" do
    body = {"deck_id": 1, "tag_id": 1}.to_json
    response = HTTP::Client.post(
      "http://localhost:3000/api/deck_tag_assignments",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    response.status_code.should eq 201
  end

  it "retrieves a deck_tag_assignment" do
    response = HTTP::Client.get("http://localhost:3000/api/deck_tag_assignments/1")
    [200, 404].should contain response.status_code
  end

  it "deletes a deck_tag_assignment" do
    response = HTTP::Client.delete("http://localhost:3000/api/deck_tag_assignments/1")
    [204, 404].should contain response.status_code
  end

end
