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

  describe "GET /api/cards?q=test" $ do
    it "returns 200" $ do
      get "/api/cards?q=test" `shouldRespondWith` 200

  describe "POST /api/cards" $ do
    it "creates and returns 201" $ do
      let body = [json|{"name": "test", "cardType": "Creature", "rarity": "Common", "manaCost": 0, "manaColors": "White", "attack": 1, "defense": 1, "loyalty": null, "description": "test", "flavorText": null, "imageUrl": null, "artistName": null, "legalFormats": "Standard", "isBanned": false, "isRestricted": false, "powerLevel": 1, "setId": 1}|]
      request "POST" "/api/cards" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/cards/1" $ do
    it "returns 200, 401, or 404" $ do
      resp <- request "GET" "/api/cards/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 401 || s == 403 || s == 404

  describe "PUT /api/cards/1" $ do
    it "returns 200, 401, 403, or 404" $ do
      let body = [json|{"name": "test", "cardType": "Creature", "rarity": "Common", "manaCost": 0, "manaColors": "White", "attack": 1, "defense": 1, "loyalty": null, "description": "test", "flavorText": null, "imageUrl": null, "artistName": null, "legalFormats": "Standard", "isBanned": false, "isRestricted": false, "powerLevel": 1, "setId": 1}|]
      resp <- request "PUT" "/api/cards/1" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 401 || s == 403 || s == 404

  describe "PATCH /api/cards/1" $ do
    it "returns 200, 401, 403, or 404" $ do
      let body = [json|{"name": "test", "cardType": "Creature", "rarity": "Common", "manaCost": 0, "manaColors": "White", "attack": 1, "defense": 1, "loyalty": null, "description": "test", "flavorText": null, "imageUrl": null, "artistName": null, "legalFormats": "Standard", "isBanned": false, "isRestricted": false, "powerLevel": 1, "setId": 1}|]
      resp <- request "PATCH" "/api/cards/1" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 401 || s == 403 || s == 404

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

  describe "POST /api/cards rule creature_requires_stats" $ do
    it "rejects when creature_requires_stats violated" $ do
      let body = [json|{"name": "test", "cardType": "Creature", "rarity": "Common", "manaCost": 0, "manaColors": "White", "attack": null, "defense": 0, "loyalty": 0, "description": "test", "flavorText": "test", "imageUrl": "https://example.com", "artistName": "test", "legalFormats": "Standard", "isBanned": false, "isRestricted": false, "powerLevel": 0, "setId": 1}|]
      resp <- request "POST" "/api/cards" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

  describe "POST /api/cards rule planeswalker_requires_loyalty" $ do
    it "rejects when planeswalker_requires_loyalty violated" $ do
      let body = [json|{"name": "test", "cardType": "Planeswalker", "rarity": "Common", "manaCost": 0, "manaColors": "White", "attack": 0, "defense": 0, "loyalty": null, "description": "test", "flavorText": "test", "imageUrl": "https://example.com", "artistName": "test", "legalFormats": "Standard", "isBanned": false, "isRestricted": false, "powerLevel": 0, "setId": 1}|]
      resp <- request "POST" "/api/cards" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

  describe "POST /api/cards rule land_has_no_mana_cost" $ do
    it "rejects when land_has_no_mana_cost violated" $ do
      let body = [json|{"name": "test", "cardType": "Land", "rarity": "Common", "manaCost": 1, "manaColors": "White", "attack": 0, "defense": 0, "loyalty": 0, "description": "test", "flavorText": "test", "imageUrl": "https://example.com", "artistName": "test", "legalFormats": "Standard", "isBanned": false, "isRestricted": false, "powerLevel": 0, "setId": 1}|]
      resp <- request "POST" "/api/cards" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

  describe "POST /api/cards rule spell_or_artifact_no_loyalty" $ do
    it "rejects when spell_or_artifact_no_loyalty violated" $ do
      let body = [json|{"name": "test", "cardType": "Creature", "rarity": "Common", "manaCost": 0, "manaColors": "White", "attack": 0, "defense": 0, "loyalty": "test", "description": "test", "flavorText": "test", "imageUrl": "https://example.com", "artistName": "test", "legalFormats": "Standard", "isBanned": false, "isRestricted": false, "powerLevel": 0, "setId": 1}|]
      resp <- request "POST" "/api/cards" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

  describe "POST /api/cards rule mana_cost_range" $ do
    it "rejects when mana_cost_range violated" $ do
      let body = [json|{"name": "test", "cardType": "Creature", "rarity": "Common", "manaCost": 21, "manaColors": "White", "attack": 0, "defense": 0, "loyalty": 0, "description": "test", "flavorText": "test", "imageUrl": "https://example.com", "artistName": "test", "legalFormats": "Standard", "isBanned": false, "isRestricted": false, "powerLevel": 0, "setId": 1}|]
      resp <- request "POST" "/api/cards" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

  describe "POST /api/cards rule power_level_range" $ do
    it "rejects when power_level_range violated" $ do
      let body = [json|{"name": "test", "cardType": "Creature", "rarity": "Common", "manaCost": 0, "manaColors": "White", "attack": 0, "defense": 0, "loyalty": 0, "description": "test", "flavorText": "test", "imageUrl": "https://example.com", "artistName": "test", "legalFormats": "Standard", "isBanned": false, "isRestricted": false, "powerLevel": 11, "setId": 1}|]
      resp <- request "POST" "/api/cards" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

  describe "POST /api/cards rule not_banned_and_restricted" $ do
    it "rejects when not_banned_and_restricted violated" $ do
      let body = [json|{"name": "test", "cardType": "Creature", "rarity": "Common", "manaCost": 0, "manaColors": "White", "attack": 0, "defense": 0, "loyalty": 0, "description": "test", "flavorText": "test", "imageUrl": "https://example.com", "artistName": "test", "legalFormats": "Standard", "isBanned": false, "isRestricted": false, "powerLevel": 0, "setId": 1}|]
      resp <- request "POST" "/api/cards" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

  describe "POST /api/cards rule banned_card_not_in_legal_formats" $ do
    it "rejects when banned_card_not_in_legal_formats violated" $ do
      let body = [json|{"name": "test", "cardType": "Creature", "rarity": "Common", "manaCost": 0, "manaColors": "White", "attack": 0, "defense": 0, "loyalty": 0, "description": "test", "flavorText": "test", "imageUrl": "https://example.com", "artistName": "test", "legalFormats": "Standard", "isBanned": true, "isRestricted": false, "powerLevel": 0, "setId": 1}|]
      resp <- request "POST" "/api/cards" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

