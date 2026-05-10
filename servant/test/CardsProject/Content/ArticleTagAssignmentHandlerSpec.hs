{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Content.ArticleTagAssignmentHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.Wai (Application)
import Data.Aeson (encode, object, (.=))
import CardsProject.App (app)
import CardsProject.Content.Types

spec :: SpecWith Application
spec = do
  describe "GET /api/article_tag_assignments" $ do
    it "returns 200" $ do
      get "/api/article_tag_assignments" `shouldRespondWith` 200

  describe "POST /api/article_tag_assignments" $ do
    it "creates and returns 201" $ do
      let body = encode (object ["articleId" .= ("test"), "tagId" .= ("test")])
      request "POST" "/api/article_tag_assignments" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/article_tag_assignments/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/article_tag_assignments/1"
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/article_tag_assignments/1" $ do
    it "returns 200 or 404" $ do
      let body = encode (object ["articleId" .= ("test"), "tagId" .= ("test")])
      resp <- request "PUT" "/api/article_tag_assignments/1" [("Content-Type","application/json")] body
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/article_tag_assignments/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/article_tag_assignments/1" [] ""
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 204 || s == 404

