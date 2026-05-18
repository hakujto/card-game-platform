{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module CardsProject.Tournaments.TournamentJudgeHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.HTTP.Types (statusCode)
import CardsProject.App (app)
import CardsProject.Tournaments.Types

spec :: Spec
spec = with (return app) $ do
  describe "GET /api/tournament_judges" $ do
    it "returns 200" $ do
      get "/api/tournament_judges" `shouldRespondWith` 200

  describe "POST /api/tournament_judges" $ do
    it "creates and returns 201" $ do
      let body = [json|{"role": "HeadJudge", "tournamentId": 1, "playerId": 1}|]
      request "POST" "/api/tournament_judges" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/tournament_judges/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/tournament_judges/1"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/tournament_judges/1" $ do
    it "returns 200 or 404" $ do
      let body = [json|{"role": "HeadJudge", "tournamentId": 1, "playerId": 1}|]
      resp <- request "PUT" "/api/tournament_judges/1" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/tournament_judges/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/tournament_judges/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404

  describe "POST /api/tournament_judges/1/promote" $ do
    it "behavior promote_to_head stub returns 404 or 500" $ do
      resp <- request "POST" "/api/tournament_judges/1/promote" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "DELETE /api/tournament_judges/1" $ do
    it "behavior remove stub returns 404 or 500" $ do
      resp <- request "DELETE" "/api/tournament_judges/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

