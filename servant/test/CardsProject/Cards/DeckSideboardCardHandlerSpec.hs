{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.DeckSideboardCardHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.Wai (Application)
import Data.Aeson (encode, object, (.=))
import CardsProject.App (app)
import CardsProject.Cards.Types

spec :: SpecWith Application
spec = do
  describe "GET /api/deck_sideboard_cards" $ do
    it "returns 200" $ do
      get "/api/deck_sideboard_cards" `shouldRespondWith` 200

  describe "POST /api/deck_sideboard_cards" $ do
    it "creates and returns 201" $ do
      let body = encode (object ["quantity" .= (0), "deckId" .= ("test"), "cardId" .= ("test")])
      request "POST" "/api/deck_sideboard_cards" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/deck_sideboard_cards/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/deck_sideboard_cards/1"
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/deck_sideboard_cards/1" $ do
    it "returns 200 or 404" $ do
      let body = encode (object ["quantity" .= (0), "deckId" .= ("test"), "cardId" .= ("test")])
      resp <- request "PUT" "/api/deck_sideboard_cards/1" [("Content-Type","application/json")] body
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/deck_sideboard_cards/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/deck_sideboard_cards/1" [] ""
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 204 || s == 404

