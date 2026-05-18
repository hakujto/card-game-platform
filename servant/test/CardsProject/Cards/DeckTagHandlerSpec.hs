{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module CardsProject.Cards.DeckTagHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.HTTP.Types (statusCode)
import CardsProject.App (app)
import CardsProject.Cards.Types

spec :: Spec
spec = with (return app) $ do
  describe "GET /api/deck_tags" $ do
    it "returns 200" $ do
      get "/api/deck_tags" `shouldRespondWith` 200

  describe "POST /api/deck_tags" $ do
    it "creates and returns 201" $ do
      let body = [json|{"name": "test", "color": "test"}|]
      request "POST" "/api/deck_tags" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/deck_tags/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/deck_tags/1"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/deck_tags/1" $ do
    it "returns 200 or 404" $ do
      let body = [json|{"name": "test", "color": "test"}|]
      resp <- request "PUT" "/api/deck_tags/1" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/deck_tags/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/deck_tags/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404

  describe "POST /api/deck_tags/1/merge" $ do
    it "behavior merge_into stub returns 404 or 500" $ do
      resp <- request "POST" "/api/deck_tags/1/merge" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 404 || s == 500

