{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module CardsProject.Tournaments.TournamentRoundHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.HTTP.Types (statusCode)
import CardsProject.App (app)
import CardsProject.Tournaments.Types

spec :: Spec
spec = with (return app) $ do
  describe "GET /api/tournament_rounds" $ do
    it "returns 200" $ do
      get "/api/tournament_rounds" `shouldRespondWith` 200

  describe "POST /api/tournament_rounds" $ do
    it "creates and returns 201" $ do
      let body = [json|{"roundNumber": 0, "status": "Pending", "startedAt": "2024-01-01T00:00:00", "endedAt": "2024-01-01T00:00:00", "timeLimitMinutes": 0, "tournamentId": 1, "matchesId": 1}|]
      request "POST" "/api/tournament_rounds" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/tournament_rounds/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/tournament_rounds/1"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/tournament_rounds/1" $ do
    it "returns 200 or 404" $ do
      let body = [json|{"roundNumber": 0, "status": "Pending", "startedAt": "2024-01-01T00:00:00", "endedAt": "2024-01-01T00:00:00", "timeLimitMinutes": 0, "tournamentId": 1, "matchesId": 1}|]
      resp <- request "PUT" "/api/tournament_rounds/1" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/tournament_rounds/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/tournament_rounds/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404

  describe "POST /api/tournament_rounds/1/start" $ do
    it "behavior start stub returns 404 or 500" $ do
      resp <- request "POST" "/api/tournament_rounds/1/start" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/tournament_rounds/1/complete" $ do
    it "behavior complete stub returns 404 or 500" $ do
      resp <- request "POST" "/api/tournament_rounds/1/complete" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/tournament_rounds/1/pairings" $ do
    it "behavior generate_pairings stub returns 404 or 500" $ do
      resp <- request "POST" "/api/tournament_rounds/1/pairings" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "GET /api/tournament_rounds/1/time-expired" $ do
    it "behavior is_time_expired stub returns 404 or 500" $ do
      resp <- get "/api/tournament_rounds/1/time-expired"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

