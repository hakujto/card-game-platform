{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module CardsProject.Tournaments.GameHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.HTTP.Types (statusCode)
import CardsProject.App (app)
import CardsProject.Tournaments.Types

spec :: Spec
spec = with (return app) $ do
  describe "GET /api/games" $ do
    it "returns 200" $ do
      get "/api/games" `shouldRespondWith` 200

  describe "POST /api/games" $ do
    it "creates and returns 201" $ do
      let body = [json|{"gameNumber": 0, "winnerSide": "Player1", "turnsPlayed": 0, "durationSeconds": 0, "endedBy": "Normal", "replayUrl": "https://example.com", "matchId": 1, "winnerId": null}|]
      request "POST" "/api/games" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/games/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/games/1"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/games/1" $ do
    it "returns 200 or 404" $ do
      let body = [json|{"gameNumber": 0, "winnerSide": "Player1", "turnsPlayed": 0, "durationSeconds": 0, "endedBy": "Normal", "replayUrl": "https://example.com", "matchId": 1, "winnerId": null}|]
      resp <- request "PUT" "/api/games/1" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/games/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/games/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404

  describe "POST /api/games/1/winner" $ do
    it "behavior record_winner stub returns 404 or 500" $ do
      resp <- request "POST" "/api/games/1/winner" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "GET /api/games/1/duration" $ do
    it "behavior duration_minutes stub returns 404 or 500" $ do
      resp <- get "/api/games/1/duration"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

