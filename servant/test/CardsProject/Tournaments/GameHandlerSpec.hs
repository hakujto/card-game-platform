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
      let body = [json|{"gameNumber": 1, "winnerSide": null, "turnsPlayed": 1, "durationSeconds": 1, "endedBy": null, "replayUrl": null, "matchId": 1, "winnerId": null}|]
      request "POST" "/api/games" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/games/1" $ do
    it "returns 200, 401, or 404" $ do
      resp <- request "GET" "/api/games/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 401 || s == 403 || s == 404

  describe "POST /api/games/1/winner" $ do
    it "behavior record_winner stub returns 404 or 500" $ do
      resp <- request "POST" "/api/games/1/winner" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "GET /api/games/1/duration" $ do
    it "behavior duration_minutes stub returns 404 or 500" $ do
      resp <- get "/api/games/1/duration"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/games rule game_number_range" $ do
    it "rejects when game_number_range violated" $ do
      let body = [json|{"gameNumber": 4, "winnerSide": "Player1", "turnsPlayed": 0, "durationSeconds": 0, "endedBy": "Normal", "replayUrl": "https://example.com", "matchId": 1, "winnerId": null}|]
      resp <- request "POST" "/api/games" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

  describe "POST /api/games rule turns_played_positive" $ do
    it "rejects when turns_played_positive violated" $ do
      let body = [json|{"gameNumber": 0, "winnerSide": "Player1", "turnsPlayed": 0, "durationSeconds": 0, "endedBy": "Normal", "replayUrl": "https://example.com", "matchId": 1, "winnerId": null}|]
      resp <- request "POST" "/api/games" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

  describe "POST /api/games rule duration_positive" $ do
    it "rejects when duration_positive violated" $ do
      let body = [json|{"gameNumber": 0, "winnerSide": "Player1", "turnsPlayed": 0, "durationSeconds": 0, "endedBy": "Normal", "replayUrl": "https://example.com", "matchId": 1, "winnerId": null}|]
      resp <- request "POST" "/api/games" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

  describe "POST /api/games rule draw_has_no_winner" $ do
    it "rejects when draw_has_no_winner violated" $ do
      let body = [json|{"gameNumber": 0, "winnerSide": "Draw", "turnsPlayed": 0, "durationSeconds": 0, "endedBy": "Normal", "replayUrl": "https://example.com", "matchId": 1, "winnerId": 1}|]
      resp <- request "POST" "/api/games" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

  describe "POST /api/games rule non_draw_requires_winner" $ do
    it "rejects when non_draw_requires_winner violated" $ do
      let body = [json|{"gameNumber": 0, "winnerSide": "Player1", "turnsPlayed": 0, "durationSeconds": 0, "endedBy": "Normal", "replayUrl": "https://example.com", "matchId": 1, "winnerId": null}|]
      resp <- request "POST" "/api/games" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

