require "spec"
require "http/client"
require "json"

describe "ArticleComment API" do
  it "lists article_comments" do
    response = HTTP::Client.get("http://localhost:3000/api/article_comments")
    response.status_code.should eq 200
  end

  it "creates a article_comment" do
    body = {"body": "test", "is_hidden": true, "article_id": 1, "author_id": 1, "parent_comment_id": 1}.to_json
    response = HTTP::Client.post(
      "http://localhost:3000/api/article_comments",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: body
    )
    response.status_code.should eq 201
  end

  it "retrieves a article_comment" do
    response = HTTP::Client.get("http://localhost:3000/api/article_comments/1")
    [200, 404].should contain response.status_code
  end

  it "deletes a article_comment" do
    response = HTTP::Client.delete("http://localhost:3000/api/article_comments/1")
    [204, 404].should contain response.status_code
  end

end
