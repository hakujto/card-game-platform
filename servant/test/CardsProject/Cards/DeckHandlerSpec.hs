{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.DeckHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.Wai (Application)
import Data.Aeson (encode, object, (.=))
import CardsProject.App (app)
import CardsProject.Cards.Types

spec :: SpecWith Application
spec = do
  describe "GET /api/decks" $ do
    it "returns 200" $ do
      get "/api/decks" `shouldRespondWith` 200

  describe "POST /api/decks" $ do
    it "creates and returns 201" $ do
      let body = encode (object ["name" .= ("test"), "description" .= ("test"), "format" .= ("Standard"), "isPublic" .= (true), "isTournamentLegal" .= (true), "archetype" .= ("Aggro"), "wins" .= (0), "losses" .= (0), "createdAt" .= ("2024-01-01T00:00:00"), "updatedAt" .= ("2024-01-01T00:00:00"), "playerId" .= ("test")])
      request "POST" "/api/decks" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/decks/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/decks/1"
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/decks/1" $ do
    it "returns 200 or 404" $ do
      let body = encode (object ["name" .= ("test"), "description" .= ("test"), "format" .= ("Standard"), "isPublic" .= (true), "isTournamentLegal" .= (true), "archetype" .= ("Aggro"), "wins" .= (0), "losses" .= (0), "createdAt" .= ("2024-01-01T00:00:00"), "updatedAt" .= ("2024-01-01T00:00:00"), "playerId" .= ("test")])
      resp <- request "PUT" "/api/decks/1" [("Content-Type","application/json")] body
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/decks/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/decks/1" [] ""
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 204 || s == 404

