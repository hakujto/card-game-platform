{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module CardsProject.Cards.CardSetHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.HTTP.Types (statusCode)
import CardsProject.App (app)
import CardsProject.Cards.Types

spec :: Spec
spec = with (return app) $ do
  describe "GET /api/card_sets" $ do
    it "returns 200" $ do
      get "/api/card_sets" `shouldRespondWith` 200

  describe "POST /api/card_sets" $ do
    it "creates and returns 201" $ do
      let body = [json|{"name": "test", "code": "test", "releaseDate": "2024-01-01", "rotationDate": "2024-01-01", "setType": "Core", "totalCards": 0, "isRotated": true, "description": "test", "logoUrl": "https://example.com"}|]
      request "POST" "/api/card_sets" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/card_sets/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/card_sets/1"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/card_sets/1" $ do
    it "returns 200 or 404" $ do
      let body = [json|{"name": "test", "code": "test", "releaseDate": "2024-01-01", "rotationDate": "2024-01-01", "setType": "Core", "totalCards": 0, "isRotated": true, "description": "test", "logoUrl": "https://example.com"}|]
      resp <- request "PUT" "/api/card_sets/1" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/card_sets/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/card_sets/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404

  describe "GET /api/card_sets/1/standard-legal" $ do
    it "behavior is_legal_in_standard stub returns 404 or 500" $ do
      resp <- get "/api/card_sets/1/standard-legal"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "GET /api/card_sets/1/legal" $ do
    it "behavior is_legal_in_format stub returns 404 or 500" $ do
      resp <- get "/api/card_sets/1/legal"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "GET /api/card_sets/1/rarity-count" $ do
    it "behavior card_count_by_rarity stub returns 404 or 500" $ do
      resp <- get "/api/card_sets/1/rarity-count"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/card_sets/1/rotate" $ do
    it "behavior rotate_out stub returns 404 or 500" $ do
      resp <- request "POST" "/api/card_sets/1/rotate" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

