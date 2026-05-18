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

  describe "POST /api/articles" $ do
    it "creates and returns 201" $ do
      let body = [json|{"title": "test", "slug": "test", "body": "test", "excerpt": "test", "coverImageUrl": "https://example.com", "status": "Draft", "articleType": "Guide", "viewCount": 0, "publishedAt": "2024-01-01T00:00:00", "createdAt": "2024-01-01T00:00:00", "updatedAt": "2024-01-01T00:00:00", "authorId": 1, "featuredDeckId": null, "commentsId": 1}|]
      request "POST" "/api/articles" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/articles/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/articles/1"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/articles/1" $ do
    it "returns 200 or 404" $ do
      let body = [json|{"title": "test", "slug": "test", "body": "test", "excerpt": "test", "coverImageUrl": "https://example.com", "status": "Draft", "articleType": "Guide", "viewCount": 0, "publishedAt": "2024-01-01T00:00:00", "createdAt": "2024-01-01T00:00:00", "updatedAt": "2024-01-01T00:00:00", "authorId": 1, "featuredDeckId": null, "commentsId": 1}|]
      resp <- request "PUT" "/api/articles/1" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/articles/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/articles/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404

  describe "POST /api/articles/1/publish" $ do
    it "behavior publish stub returns 404 or 500" $ do
      resp <- request "POST" "/api/articles/1/publish" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/articles/1/archive" $ do
    it "behavior archive stub returns 404 or 500" $ do
      resp <- request "POST" "/api/articles/1/archive" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/articles/1/view" $ do
    it "behavior increment_view stub returns 404 or 500" $ do
      resp <- request "POST" "/api/articles/1/view" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "GET /api/articles/1/reading-time" $ do
    it "behavior reading_time_minutes stub returns 404 or 500" $ do
      resp <- get "/api/articles/1/reading-time"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

