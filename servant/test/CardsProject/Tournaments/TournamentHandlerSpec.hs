{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module CardsProject.Tournaments.TournamentHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.HTTP.Types (statusCode)
import CardsProject.App (app)
import CardsProject.Tournaments.Types

spec :: Spec
spec = with (return app) $ do
  describe "GET /api/tournaments" $ do
    it "returns 200" $ do
      get "/api/tournaments" `shouldRespondWith` 200

  describe "POST /api/tournaments" $ do
    it "creates and returns 201" $ do
      let body = [json|{"name": "test", "description": "test", "format": "Standard", "tournamentType": "Swiss", "status": "Draft", "maxPlayers": 0, "entryFee": "1.00", "prizePool": "1.00", "startTime": "2024-01-01T00:00:00", "endTime": "2024-01-01T00:00:00", "isOnline": true, "location": "test", "rulesText": "test", "createdAt": "2024-01-01T00:00:00", "seasonId": 1, "organizerId": 1, "registrationsId": null, "roundsId": null, "prizesId": null}|]
      request "POST" "/api/tournaments" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/tournaments/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/tournaments/1"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/tournaments/1" $ do
    it "returns 200 or 404" $ do
      let body = [json|{"name": "test", "description": "test", "format": "Standard", "tournamentType": "Swiss", "status": "Draft", "maxPlayers": 0, "entryFee": "1.00", "prizePool": "1.00", "startTime": "2024-01-01T00:00:00", "endTime": "2024-01-01T00:00:00", "isOnline": true, "location": "test", "rulesText": "test", "createdAt": "2024-01-01T00:00:00", "seasonId": 1, "organizerId": 1, "registrationsId": null, "roundsId": null, "prizesId": null}|]
      resp <- request "PUT" "/api/tournaments/1" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/tournaments/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/tournaments/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404

  describe "POST /api/tournaments/1/start" $ do
    it "behavior start stub returns 404 or 500" $ do
      resp <- request "POST" "/api/tournaments/1/start" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 404 || s == 500

  describe "POST /api/tournaments/1/cancel" $ do
    it "behavior cancel stub returns 404 or 500" $ do
      resp <- request "POST" "/api/tournaments/1/cancel" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 404 || s == 500

  describe "POST /api/tournaments/1/complete" $ do
    it "behavior complete stub returns 404 or 500" $ do
      resp <- request "POST" "/api/tournaments/1/complete" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 404 || s == 500

  describe "POST /api/tournaments/1/rounds" $ do
    it "behavior generate_round stub returns 404 or 500" $ do
      resp <- request "POST" "/api/tournaments/1/rounds" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 404 || s == 500

  describe "GET /api/tournaments/1/prizes" $ do
    it "behavior calculate_prize_distribution stub returns 404 or 500" $ do
      resp <- get "/api/tournaments/1/prizes"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 404 || s == 500

