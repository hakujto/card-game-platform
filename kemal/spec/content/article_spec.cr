require "spec"
require "http/client"
require "json"

describe "Article API" do
  it "lists articles" do
    response = HTTP::Client.get("http://localhost:3000/api/articles")
    response.status_code.should eq 200
  end

  it "searches articles" do
    response = HTTP::Client.get("http://localhost:3000/api/articles?q=test")
    response.status_code.should eq 200
  end

  it "creates a article" do
    body = {"title": "test", "slug": "test", "body": "test", "excerpt": "test", "cover_image_url": "https://example.com", "status": "D", "article_type": "G", "language": "E", "view_count": 1, "likes_count": 1, "total_views_alltime": 1, "is_featured": true, "publishedAt": "2024-01-01T00:00:00Z", "author_id": 1, "featured_deck_id": 1}.to_json
    response = HTTP::Client.post(
      "http://localhost:3000/api/articles",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    response.status_code.should eq 201
  end

  it "retrieves a article" do
    response = HTTP::Client.get("http://localhost:3000/api/articles/1")
    [200, 404].should contain response.status_code
  end

  it "updates a article" do
    body = {"excerpt": "test"}.to_json
    response = HTTP::Client.patch(
      "http://localhost:3000/api/articles/1",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    [200, 404].should contain response.status_code
  end

end
