{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.TournamentRoundHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.Wai (Application)
import Data.Aeson (encode, object, (.=))
import CardsProject.App (app)
import CardsProject.Tournaments.Types

spec :: SpecWith Application
spec = do
  describe "GET /api/tournament_rounds" $ do
    it "returns 200" $ do
      get "/api/tournament_rounds" `shouldRespondWith` 200

  describe "POST /api/tournament_rounds" $ do
    it "creates and returns 201" $ do
      let body = encode (object ["roundNumber" .= (0), "status" .= ("Pending"), "startedAt" .= ("2024-01-01T00:00:00"), "endedAt" .= ("2024-01-01T00:00:00"), "timeLimitMinutes" .= (0), "tournamentId" .= ("test"), "matchesId" .= ("test")])
      request "POST" "/api/tournament_rounds" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/tournament_rounds/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/tournament_rounds/1"
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/tournament_rounds/1" $ do
    it "returns 200 or 404" $ do
      let body = encode (object ["roundNumber" .= (0), "status" .= ("Pending"), "startedAt" .= ("2024-01-01T00:00:00"), "endedAt" .= ("2024-01-01T00:00:00"), "timeLimitMinutes" .= (0), "tournamentId" .= ("test"), "matchesId" .= ("test")])
      resp <- request "PUT" "/api/tournament_rounds/1" [("Content-Type","application/json")] body
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/tournament_rounds/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/tournament_rounds/1" [] ""
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 204 || s == 404

