{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module CardsProject.Content.ArticleCommentHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.HTTP.Types (statusCode)
import CardsProject.App (app)
import CardsProject.Content.Types

spec :: Spec
spec = with (return app) $ do
  describe "GET /api/article_comments" $ do
    it "returns 200" $ do
      get "/api/article_comments" `shouldRespondWith` 200

  describe "POST /api/article_comments" $ do
    it "creates and returns 201" $ do
      let body = [json|{"body": "test", "isHidden": true, "createdAt": "2024-01-01T00:00:00", "articleId": null, "authorId": 1, "parentCommentId": null}|]
      request "POST" "/api/article_comments" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/article_comments/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/article_comments/1"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/article_comments/1" $ do
    it "returns 200 or 404" $ do
      let body = [json|{"body": "test", "isHidden": true, "createdAt": "2024-01-01T00:00:00", "articleId": null, "authorId": 1, "parentCommentId": null}|]
      resp <- request "PUT" "/api/article_comments/1" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/article_comments/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/article_comments/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404

  describe "POST /api/article_comments/1/hide" $ do
    it "behavior hide stub returns 404 or 500" $ do
      resp <- request "POST" "/api/article_comments/1/hide" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 404 || s == 500

  describe "POST /api/article_comments/1/unhide" $ do
    it "behavior unhide stub returns 404 or 500" $ do
      resp <- request "POST" "/api/article_comments/1/unhide" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 404 || s == 500

