{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Content.ArticleCommentHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.Wai (Application)
import Data.Aeson (encode, object, (.=))
import CardsProject.App (app)
import CardsProject.Content.Types

spec :: SpecWith Application
spec = do
  describe "GET /api/article_comments" $ do
    it "returns 200" $ do
      get "/api/article_comments" `shouldRespondWith` 200

  describe "POST /api/article_comments" $ do
    it "creates and returns 201" $ do
      let body = encode (object ["body" .= ("test"), "isHidden" .= (true), "createdAt" .= ("2024-01-01T00:00:00"), "articleId" .= ("test"), "authorId" .= ("test"), "parentCommentId" .= ("test")])
      request "POST" "/api/article_comments" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/article_comments/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/article_comments/1"
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/article_comments/1" $ do
    it "returns 200 or 404" $ do
      let body = encode (object ["body" .= ("test"), "isHidden" .= (true), "createdAt" .= ("2024-01-01T00:00:00"), "articleId" .= ("test"), "authorId" .= ("test"), "parentCommentId" .= ("test")])
      resp <- request "PUT" "/api/article_comments/1" [("Content-Type","application/json")] body
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/article_comments/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/article_comments/1" [] ""
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 204 || s == 404

