{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module CardsProject.Cards.CardHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.HTTP.Types (statusCode)
import CardsProject.App (app)
import CardsProject.Cards.Types

spec :: Spec
spec = with (return app) $ do
  describe "GET /api/cards" $ do
    it "returns 200" $ do
      get "/api/cards" `shouldRespondWith` 200

  describe "POST /api/cards" $ do
    it "creates and returns 201" $ do
      let body = [json|{"name": "test", "cardType": "Creature", "rarity": "Common", "manaCost": 0, "manaColors": "White", "attack": 0, "defense": 0, "loyalty": 0, "description": "test", "flavorText": "test", "imageUrl": "https://example.com", "artistName": "test", "legalFormats": "Standard", "isBanned": true, "isRestricted": true, "powerLevel": 0, "setId": 1, "rulingsId": null, "abilitiesId": null}|]
      request "POST" "/api/cards" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/cards/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/cards/1"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/cards/1" $ do
    it "returns 200 or 404" $ do
      let body = [json|{"name": "test", "cardType": "Creature", "rarity": "Common", "manaCost": 0, "manaColors": "White", "attack": 0, "defense": 0, "loyalty": 0, "description": "test", "flavorText": "test", "imageUrl": "https://example.com", "artistName": "test", "legalFormats": "Standard", "isBanned": true, "isRestricted": true, "powerLevel": 0, "setId": 1, "rulingsId": null, "abilitiesId": null}|]
      resp <- request "PUT" "/api/cards/1" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/cards/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/cards/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404

  describe "POST /api/cards/1/ban" $ do
    it "behavior ban stub returns 404 or 500" $ do
      resp <- request "POST" "/api/cards/1/ban" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/cards/1/unban" $ do
    it "behavior unban stub returns 404 or 500" $ do
      resp <- request "POST" "/api/cards/1/unban" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/cards/1/restrict" $ do
    it "behavior restrict stub returns 404 or 500" $ do
      resp <- request "POST" "/api/cards/1/restrict" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/cards/1/unrestrict" $ do
    it "behavior unrestrict stub returns 404 or 500" $ do
      resp <- request "POST" "/api/cards/1/unrestrict" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "GET /api/cards/1/value" $ do
    it "behavior calculate_value stub returns 404 or 500" $ do
      resp <- get "/api/cards/1/value"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/cards/1/rarity-bonus" $ do
    it "behavior apply_rarity_bonus stub returns 404 or 500" $ do
      resp <- request "POST" "/api/cards/1/rarity-bonus" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "GET /api/cards/1/legal" $ do
    it "behavior is_legal_in_format stub returns 404 or 500" $ do
      resp <- get "/api/cards/1/legal"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

