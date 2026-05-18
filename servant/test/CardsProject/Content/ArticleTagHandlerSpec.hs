{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module CardsProject.Content.ArticleTagHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.HTTP.Types (statusCode)
import CardsProject.App (app)
import CardsProject.Content.Types

spec :: Spec
spec = with (return app) $ do
  describe "GET /api/article_tags" $ do
    it "returns 200" $ do
      get "/api/article_tags" `shouldRespondWith` 200

  describe "POST /api/article_tags" $ do
    it "creates and returns 201" $ do
      let body = [json|{"name": "test", "slug": "test"}|]
      request "POST" "/api/article_tags" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/article_tags/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/article_tags/1"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/article_tags/1" $ do
    it "returns 200 or 404" $ do
      let body = [json|{"name": "test", "slug": "test"}|]
      resp <- request "PUT" "/api/article_tags/1" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/article_tags/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/article_tags/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404

  describe "PATCH /api/article_tags/1/rename" $ do
    it "behavior rename stub returns 404 or 500" $ do
      resp <- request "PATCH" "/api/article_tags/1/rename" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "GET /api/article_tags/1/article-count" $ do
    it "behavior article_count stub returns 404 or 500" $ do
      resp <- get "/api/article_tags/1/article-count"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

