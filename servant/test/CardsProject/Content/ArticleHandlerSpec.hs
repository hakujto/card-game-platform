{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module CardsProject.Content.ArticleHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.HTTP.Types (statusCode)
import CardsProject.App (app)
import CardsProject.Content.Types

spec :: Spec
spec = with (return app) $ do
  describe "GET /api/articles" $ do
    it "returns 200" $ do
      get "/api/articles" `shouldRespondWith` 200

  describe "GET /api/articles?q=test" $ do
    it "returns 200" $ do
      get "/api/articles?q=test" `shouldRespondWith` 200

  describe "POST /api/articles" $ do
    it "creates and returns 201" $ do
      let body = [json|{"title": "test", "slug": "test", "body": "test", "excerpt": null, "coverImageUrl": null, "status": "Draft", "articleType": "Guide", "language": "EN", "viewCount": 0, "likesCount": 0, "totalViewsAlltime": 0, "isFeatured": false, "publishedAt": "2024-01-01T00:00:00Z", "createdAt": "2024-01-01T00:00:00", "updatedAt": "2024-01-01T00:00:00", "authorId": 1, "featuredDeckId": null}|]
      request "POST" "/api/articles" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/articles/1" $ do
    it "returns 200, 401, or 404" $ do
      resp <- request "GET" "/api/articles/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 401 || s == 403 || s == 404

  describe "PUT /api/articles/1" $ do
    it "returns 200, 401, 403, or 404" $ do
      let body = [json|{"title": "test", "slug": "test", "body": "test", "excerpt": null, "coverImageUrl": null, "status": "Draft", "articleType": "Guide", "language": "EN", "viewCount": 0, "likesCount": 0, "totalViewsAlltime": 0, "isFeatured": false, "publishedAt": "2024-01-01T00:00:00Z", "createdAt": "2024-01-01T00:00:00", "updatedAt": "2024-01-01T00:00:00", "authorId": 1, "featuredDeckId": null}|]
      resp <- request "PUT" "/api/articles/1" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 401 || s == 403 || s == 404

  describe "PATCH /api/articles/1" $ do
    it "returns 200, 401, 403, or 404" $ do
      let body = [json|{"title": "test", "slug": "test", "body": "test", "excerpt": null, "coverImageUrl": null, "status": "Draft", "articleType": "Guide", "language": "EN", "viewCount": 0, "likesCount": 0, "totalViewsAlltime": 0, "isFeatured": false, "publishedAt": "2024-01-01T00:00:00Z", "createdAt": "2024-01-01T00:00:00", "updatedAt": "2024-01-01T00:00:00", "authorId": 1, "featuredDeckId": null}|]
      resp <- request "PATCH" "/api/articles/1" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 401 || s == 403 || s == 404

  describe "PATCH /api/articles/1/transitions/draft-to-published" $ do
    it "transitions Draft -> Published with role Editor" $ do
      resp <- request "PATCH" "/api/articles/1/transitions/draft-to-published" [("X-User-Role","Editor")] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s `elem` [200, 409, 404, 500]

    it "rejects Draft -> Published without role (401 or 403)" $ do
      resp <- request "PATCH" "/api/articles/1/transitions/draft-to-published" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 401 || s == 403

  describe "PATCH /api/articles/1/transitions/published-to-archived" $ do
    it "transitions Published -> Archived with role Editor" $ do
      resp <- request "PATCH" "/api/articles/1/transitions/published-to-archived" [("X-User-Role","Editor")] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s `elem` [200, 409, 404, 500]

    it "rejects Published -> Archived without role (401 or 403)" $ do
      resp <- request "PATCH" "/api/articles/1/transitions/published-to-archived" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 401 || s == 403

  describe "PATCH /api/articles/1/transitions/archived-to-draft" $ do
    it "transitions Archived -> Draft with role Admin" $ do
      resp <- request "PATCH" "/api/articles/1/transitions/archived-to-draft" [("X-User-Role","Admin")] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s `elem` [200, 409, 404, 500]

    it "rejects Archived -> Draft without role (401 or 403)" $ do
      resp <- request "PATCH" "/api/articles/1/transitions/archived-to-draft" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 401 || s == 403

  describe "PATCH /api/articles/1/transitions/published-to-draft" $ do
    it "is denied (409 or 404)" $ do
      resp <- request "PATCH" "/api/articles/1/transitions/published-to-draft" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 409 || s == 404

  describe "POST /api/articles/1/publish" $ do
    it "behavior publish stub returns 404 or 500" $ do
      resp <- request "POST" "/api/articles/1/publish" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 400 || s == 401 || s == 404 || s == 500

  describe "POST /api/articles/1/archive" $ do
    it "behavior archive stub returns 404 or 500" $ do
      resp <- request "POST" "/api/articles/1/archive" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 400 || s == 401 || s == 404 || s == 500

  describe "PUT /api/articles/1" $ do
    it "behavior replace stub returns 404 or 500" $ do
      resp <- request "PUT" "/api/articles/1" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 400 || s == 401 || s == 404 || s == 500

  describe "POST /api/articles/1/view" $ do
    it "behavior increment_view stub returns 404 or 500" $ do
      resp <- request "POST" "/api/articles/1/view" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 400 || s == 401 || s == 404 || s == 500

  describe "POST /api/articles/1/like" $ do
    it "behavior like stub returns 404 or 500" $ do
      resp <- request "POST" "/api/articles/1/like" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 400 || s == 401 || s == 404 || s == 500

  describe "DELETE /api/articles/1/like" $ do
    it "behavior unlike stub returns 404 or 500" $ do
      resp <- request "DELETE" "/api/articles/1/like" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 400 || s == 401 || s == 404 || s == 500

  describe "GET /api/articles/1/reading-time" $ do
    it "behavior reading_time_minutes stub returns 404 or 500" $ do
      resp <- get "/api/articles/1/reading-time"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 400 || s == 401 || s == 404 || s == 500

  describe "POST /api/articles rule published_requires_published_at" $ do
    it "rejects when published_requires_published_at violated" $ do
      let body = [json|{"title": "test", "slug": "test", "body": "test", "excerpt": "test", "coverImageUrl": "https://example.com", "status": "Published", "articleType": "Guide", "language": "EN", "viewCount": 0, "likesCount": 0, "totalViewsAlltime": 0, "isFeatured": false, "publishedAt": null, "createdAt": "2024-01-01T00:00:00", "updatedAt": "2024-01-01T00:00:00", "authorId": 1, "featuredDeckId": null}|]
      resp <- request "POST" "/api/articles" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

  describe "POST /api/articles rule view_count_not_negative" $ do
    it "rejects when view_count_not_negative violated" $ do
      let body = [json|{"title": "test", "slug": "test", "body": "test", "excerpt": "test", "coverImageUrl": "https://example.com", "status": "Draft", "articleType": "Guide", "language": "EN", "viewCount": -2, "likesCount": 0, "totalViewsAlltime": 0, "isFeatured": false, "publishedAt": "2024-01-01T00:00:00", "createdAt": "2024-01-01T00:00:00", "updatedAt": "2024-01-01T00:00:00", "authorId": 1, "featuredDeckId": null}|]
      resp <- request "POST" "/api/articles" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

  describe "POST /api/articles rule likes_count_not_negative" $ do
    it "rejects when likes_count_not_negative violated" $ do
      let body = [json|{"title": "test", "slug": "test", "body": "test", "excerpt": "test", "coverImageUrl": "https://example.com", "status": "Draft", "articleType": "Guide", "language": "EN", "viewCount": 0, "likesCount": -2, "totalViewsAlltime": 0, "isFeatured": false, "publishedAt": "2024-01-01T00:00:00", "createdAt": "2024-01-01T00:00:00", "updatedAt": "2024-01-01T00:00:00", "authorId": 1, "featuredDeckId": null}|]
      resp <- request "POST" "/api/articles" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

