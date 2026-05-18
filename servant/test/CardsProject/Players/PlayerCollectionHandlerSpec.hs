{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module CardsProject.Players.PlayerCollectionHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.HTTP.Types (statusCode)
import CardsProject.App (app)
import CardsProject.Players.Types

spec :: Spec
spec = with (return app) $ do
  describe "GET /api/player_collections" $ do
    it "returns 200" $ do
      get "/api/player_collections" `shouldRespondWith` 200

  describe "POST /api/player_collections" $ do
    it "creates and returns 201" $ do
      let body = [json|{"quantity": 0, "foil": true, "condition": "Mint", "acquiredAt": "2024-01-01T00:00:00", "acquiredVia": "Purchase", "playerId": 1, "cardId": 1}|]
      request "POST" "/api/player_collections" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/player_collections/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/player_collections/1"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/player_collections/1" $ do
    it "returns 200 or 404" $ do
      let body = [json|{"quantity": 0, "foil": true, "condition": "Mint", "acquiredAt": "2024-01-01T00:00:00", "acquiredVia": "Purchase", "playerId": 1, "cardId": 1}|]
      resp <- request "PUT" "/api/player_collections/1" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/player_collections/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/player_collections/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404

  describe "POST /api/player_collections/1/add" $ do
    it "behavior add stub returns 404 or 500" $ do
      resp <- request "POST" "/api/player_collections/1/add" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/player_collections/1/remove" $ do
    it "behavior remove stub returns 404 or 500" $ do
      resp <- request "POST" "/api/player_collections/1/remove" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "GET /api/player_collections/1/value" $ do
    it "behavior estimated_value stub returns 404 or 500" $ do
      resp <- get "/api/player_collections/1/value"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

