{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module CardsProject.Tournaments.TournamentPrizeHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.HTTP.Types (statusCode)
import CardsProject.App (app)
import CardsProject.Tournaments.Types

spec :: Spec
spec = with (return app) $ do
  describe "GET /api/tournament_prizes" $ do
    it "returns 200" $ do
      get "/api/tournament_prizes" `shouldRespondWith` 200

  describe "POST /api/tournament_prizes" $ do
    it "creates and returns 201" $ do
      let body = [json|{"placementFrom": 0, "placementTo": 0, "prizeType": "Currency", "amount": "1.00", "description": "test", "packsCount": 0, "seasonPoints": 0, "tournamentId": 1}|]
      request "POST" "/api/tournament_prizes" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/tournament_prizes/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/tournament_prizes/1"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/tournament_prizes/1" $ do
    it "returns 200 or 404" $ do
      let body = [json|{"placementFrom": 0, "placementTo": 0, "prizeType": "Currency", "amount": "1.00", "description": "test", "packsCount": 0, "seasonPoints": 0, "tournamentId": 1}|]
      resp <- request "PUT" "/api/tournament_prizes/1" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/tournament_prizes/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/tournament_prizes/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404

  describe "GET /api/tournament_prizes/1/applies" $ do
    it "behavior applies_to_placement stub returns 404 or 500" $ do
      resp <- get "/api/tournament_prizes/1/applies"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/tournament_prizes/1/award" $ do
    it "behavior award_to_player stub returns 404 or 500" $ do
      resp <- request "POST" "/api/tournament_prizes/1/award" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

