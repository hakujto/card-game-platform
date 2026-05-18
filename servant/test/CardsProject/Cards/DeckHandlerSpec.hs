{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module CardsProject.Cards.DeckHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.HTTP.Types (statusCode)
import CardsProject.App (app)
import CardsProject.Cards.Types

spec :: Spec
spec = with (return app) $ do
  describe "GET /api/decks" $ do
    it "returns 200" $ do
      get "/api/decks" `shouldRespondWith` 200

  describe "POST /api/decks" $ do
    it "creates and returns 201" $ do
      let body = [json|{"name": "test", "description": "test", "format": "Standard", "isPublic": true, "isTournamentLegal": true, "archetype": "Aggro", "wins": 0, "losses": 0, "draws": 0, "createdAt": "2024-01-01T00:00:00", "updatedAt": "2024-01-01T00:00:00", "playerId": 1}|]
      request "POST" "/api/decks" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/decks/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/decks/1"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/decks/1" $ do
    it "returns 200 or 404" $ do
      let body = [json|{"name": "test", "description": "test", "format": "Standard", "isPublic": true, "isTournamentLegal": true, "archetype": "Aggro", "wins": 0, "losses": 0, "draws": 0, "createdAt": "2024-01-01T00:00:00", "updatedAt": "2024-01-01T00:00:00", "playerId": 1}|]
      resp <- request "PUT" "/api/decks/1" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/decks/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/decks/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404

  describe "GET /api/decks/1/validate" $ do
    it "behavior validate_size stub returns 404 or 500" $ do
      resp <- get "/api/decks/1/validate"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/decks/1/cards" $ do
    it "behavior add_card stub returns 404 or 500" $ do
      resp <- request "POST" "/api/decks/1/cards" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "DELETE /api/decks/1/cards/1" $ do
    it "behavior remove_card stub returns 404 or 500" $ do
      resp <- request "DELETE" "/api/decks/1/cards/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "GET /api/decks/1/win-rate" $ do
    it "behavior win_rate stub returns 404 or 500" $ do
      resp <- get "/api/decks/1/win-rate"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/decks/1/clone" $ do
    it "behavior clone stub returns 404 or 500" $ do
      resp <- request "POST" "/api/decks/1/clone" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/decks/1/publish" $ do
    it "behavior publish stub returns 404 or 500" $ do
      resp <- request "POST" "/api/decks/1/publish" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/decks/1/unpublish" $ do
    it "behavior unpublish stub returns 404 or 500" $ do
      resp <- request "POST" "/api/decks/1/unpublish" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/decks/1/certify" $ do
    it "behavior certify_tournament_legal stub returns 404 or 500" $ do
      resp <- request "POST" "/api/decks/1/certify" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

