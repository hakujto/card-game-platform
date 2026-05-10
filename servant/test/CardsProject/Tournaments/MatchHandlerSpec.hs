{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.MatchHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.Wai (Application)
import Data.Aeson (encode, object, (.=))
import CardsProject.App (app)
import CardsProject.Tournaments.Types

spec :: SpecWith Application
spec = do
  describe "GET /api/matches" $ do
    it "returns 200" $ do
      get "/api/matches" `shouldRespondWith` 200

  describe "POST /api/matches" $ do
    it "creates and returns 201" $ do
      let body = encode (object ["tableNumber" .= (0), "status" .= ("Pending"), "player1Wins" .= (0), "player2Wins" .= (0), "startedAt" .= ("2024-01-01T00:00:00"), "endedAt" .= ("2024-01-01T00:00:00"), "resultNotes" .= ("test"), "roundId" .= ("test"), "player1Id" .= ("test"), "player2Id" .= ("test"), "gamesId" .= ("test")])
      request "POST" "/api/matches" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/matches/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/matches/1"
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/matches/1" $ do
    it "returns 200 or 404" $ do
      let body = encode (object ["tableNumber" .= (0), "status" .= ("Pending"), "player1Wins" .= (0), "player2Wins" .= (0), "startedAt" .= ("2024-01-01T00:00:00"), "endedAt" .= ("2024-01-01T00:00:00"), "resultNotes" .= ("test"), "roundId" .= ("test"), "player1Id" .= ("test"), "player2Id" .= ("test"), "gamesId" .= ("test")])
      resp <- request "PUT" "/api/matches/1" [("Content-Type","application/json")] body
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/matches/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/matches/1" [] ""
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 204 || s == 404

