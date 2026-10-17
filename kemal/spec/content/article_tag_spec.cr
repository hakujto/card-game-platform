require "spec"
require "http/client"
require "json"

describe "ArticleTag API" do
  it "lists article_tags" do
    response = HTTP::Client.get("http://localhost:3000/api/article_tags")
    response.status_code.should eq 200
  end

  it "searches article_tags" do
    response = HTTP::Client.get("http://localhost:3000/api/article_tags?q=test")
    response.status_code.should eq 200
  end

  it "creates a article_tag" do
    body = {"name": "test", "slug": "test"}.to_json
    response = HTTP::Client.post(
      "http://localhost:3000/api/article_tags",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    response.status_code.should eq 201
  end

  it "retrieves a article_tag" do
    response = HTTP::Client.get("http://localhost:3000/api/article_tags/1")
    [200, 404].should contain response.status_code
  end

  it "updates a article_tag" do
    body = {"name": "test"}.to_json
    response = HTTP::Client.patch(
      "http://localhost:3000/api/article_tags/1",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    [200, 404].should contain response.status_code
  end

  it "deletes a article_tag" do
    response = HTTP::Client.delete("http://localhost:3000/api/article_tags/1")
    [204, 404].should contain response.status_code
  end

end
