{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Content.ArticleHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.Wai (Application)
import Data.Aeson (encode, object, (.=))
import CardsProject.App (app)
import CardsProject.Content.Types

spec :: SpecWith Application
spec = do
  describe "GET /api/articles" $ do
    it "returns 200" $ do
      get "/api/articles" `shouldRespondWith` 200

  describe "POST /api/articles" $ do
    it "creates and returns 201" $ do
      let body = encode (object ["title" .= ("test"), "slug" .= ("test"), "body" .= ("test"), "excerpt" .= ("test"), "coverImageUrl" .= ("https://example.com"), "status" .= ("Draft"), "articleType" .= ("Guide"), "viewCount" .= (0), "publishedAt" .= ("2024-01-01T00:00:00"), "createdAt" .= ("2024-01-01T00:00:00"), "updatedAt" .= ("2024-01-01T00:00:00"), "authorId" .= ("test"), "featuredDeckId" .= ("test"), "commentsId" .= ("test")])
      request "POST" "/api/articles" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/articles/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/articles/1"
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/articles/1" $ do
    it "returns 200 or 404" $ do
      let body = encode (object ["title" .= ("test"), "slug" .= ("test"), "body" .= ("test"), "excerpt" .= ("test"), "coverImageUrl" .= ("https://example.com"), "status" .= ("Draft"), "articleType" .= ("Guide"), "viewCount" .= (0), "publishedAt" .= ("2024-01-01T00:00:00"), "createdAt" .= ("2024-01-01T00:00:00"), "updatedAt" .= ("2024-01-01T00:00:00"), "authorId" .= ("test"), "featuredDeckId" .= ("test"), "commentsId" .= ("test")])
      resp <- request "PUT" "/api/articles/1" [("Content-Type","application/json")] body
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/articles/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/articles/1" [] ""
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 204 || s == 404

