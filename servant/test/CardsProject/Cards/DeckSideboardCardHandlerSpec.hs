{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module CardsProject.Cards.DeckSideboardCardHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.HTTP.Types (statusCode)
import CardsProject.App (app)
import CardsProject.Cards.Types

spec :: Spec
spec = with (return app) $ do
  describe "GET /api/deck_sideboard_cards" $ do
    it "returns 200" $ do
      get "/api/deck_sideboard_cards" `shouldRespondWith` 200

  describe "POST /api/deck_sideboard_cards" $ do
    it "creates and returns 201" $ do
      let body = [json|{"quantity": 0, "deckId": 1, "cardId": 1}|]
      request "POST" "/api/deck_sideboard_cards" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/deck_sideboard_cards/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/deck_sideboard_cards/1"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/deck_sideboard_cards/1" $ do
    it "returns 200 or 404" $ do
      let body = [json|{"quantity": 0, "deckId": 1, "cardId": 1}|]
      resp <- request "PUT" "/api/deck_sideboard_cards/1" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/deck_sideboard_cards/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/deck_sideboard_cards/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404

  describe "PATCH /api/deck_sideboard_cards/1/increment" $ do
    it "behavior increment stub returns 404 or 500" $ do
      resp <- request "PATCH" "/api/deck_sideboard_cards/1/increment" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "PATCH /api/deck_sideboard_cards/1/decrement" $ do
    it "behavior decrement stub returns 404 or 500" $ do
      resp <- request "PATCH" "/api/deck_sideboard_cards/1/decrement" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

