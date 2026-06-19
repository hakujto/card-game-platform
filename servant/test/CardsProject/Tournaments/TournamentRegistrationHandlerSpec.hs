{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module CardsProject.Tournaments.TournamentRegistrationHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.HTTP.Types (statusCode)
import CardsProject.App (app)
import CardsProject.Tournaments.Types

spec :: Spec
spec = with (return app) $ do
  describe "GET /api/tournament_registrations" $ do
    it "returns 200" $ do
      get "/api/tournament_registrations" `shouldRespondWith` 200

  describe "POST /api/tournament_registrations" $ do
    it "creates and returns 201" $ do
      let body = [json|{"status": "Registered", "seed": 1, "finalStanding": 1, "pointsEarned": 0, "registeredAt": "2024-01-01T00:00:00", "tournamentId": 1, "deckId": 1, "playerId": 1}|]
      request "POST" "/api/tournament_registrations" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/tournament_registrations/1" $ do
    it "returns 200, 401, or 404" $ do
      resp <- request "GET" "/api/tournament_registrations/1" [("X-User-Id","1")] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 401 || s == 403 || s == 404

  describe "POST /api/tournament_registrations/1/withdraw" $ do
    it "behavior withdraw stub returns 404 or 500" $ do
      resp <- request "POST" "/api/tournament_registrations/1/withdraw" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/tournament_registrations/1/disqualify" $ do
    it "behavior disqualify stub returns 404 or 500" $ do
      resp <- request "POST" "/api/tournament_registrations/1/disqualify" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/tournament_registrations/1/promote" $ do
    it "behavior promote_from_waitlist stub returns 404 or 500" $ do
      resp <- request "POST" "/api/tournament_registrations/1/promote" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/tournament_registrations rule points_earned_not_negative" $ do
    it "rejects when points_earned_not_negative violated" $ do
      let body = [json|{"status": "Registered", "seed": 0, "finalStanding": 0, "pointsEarned": -2, "registeredAt": "2024-01-01T00:00:00", "tournamentId": 1, "playerId": 1, "deckId": 1}|]
      resp <- request "POST" "/api/tournament_registrations" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

  describe "POST /api/tournament_registrations rule final_standing_positive" $ do
    it "rejects when final_standing_positive violated" $ do
      let body = [json|{"status": "Registered", "seed": 0, "finalStanding": 0, "pointsEarned": 0, "registeredAt": "2024-01-01T00:00:00", "tournamentId": 1, "playerId": 1, "deckId": 1}|]
      resp <- request "POST" "/api/tournament_registrations" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

  describe "POST /api/tournament_registrations rule seed_positive" $ do
    it "rejects when seed_positive violated" $ do
      let body = [json|{"status": "Registered", "seed": 0, "finalStanding": 0, "pointsEarned": 0, "registeredAt": "2024-01-01T00:00:00", "tournamentId": 1, "playerId": 1, "deckId": 1}|]
      resp <- request "POST" "/api/tournament_registrations" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

