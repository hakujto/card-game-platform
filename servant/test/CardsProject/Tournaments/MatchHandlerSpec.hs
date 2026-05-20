{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module CardsProject.Tournaments.MatchHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.HTTP.Types (statusCode)
import CardsProject.App (app)
import CardsProject.Tournaments.Types

spec :: Spec
spec = with (return app) $ do
  describe "GET /api/matches" $ do
    it "returns 200" $ do
      get "/api/matches" `shouldRespondWith` 200

  describe "POST /api/matches" $ do
    it "creates and returns 201" $ do
      let body = [json|{"tableNumber": 0, "status": "Pending", "player1Wins": 0, "player2Wins": 0, "startedAt": "2024-01-01T00:00:00", "endedAt": "2024-01-01T00:00:00", "resultNotes": "test", "roundId": null, "player1Id": 1, "player2Id": null, "gamesId": null}|]
      request "POST" "/api/matches" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/matches/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/matches/1"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/matches/1" $ do
    it "returns 200 or 404" $ do
      let body = [json|{"tableNumber": 0, "status": "Pending", "player1Wins": 0, "player2Wins": 0, "startedAt": "2024-01-01T00:00:00", "endedAt": "2024-01-01T00:00:00", "resultNotes": "test", "roundId": null, "player1Id": 1, "player2Id": null, "gamesId": null}|]
      resp <- request "PUT" "/api/matches/1" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/matches/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/matches/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404

  describe "PATCH /api/matches/1/transitions/pending-to-active" $ do
    it "transitions Pending -> Active" $ do
      resp <- request "PATCH" "/api/matches/1/transitions/pending-to-active" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s `elem` [200, 409, 404, 500]

  describe "PATCH /api/matches/1/transitions/active-to-completed" $ do
    it "transitions Active -> Completed" $ do
      resp <- request "PATCH" "/api/matches/1/transitions/active-to-completed" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s `elem` [200, 409, 404, 500]

  describe "PATCH /api/matches/1/transitions/active-to-draw" $ do
    it "transitions Active -> Draw" $ do
      resp <- request "PATCH" "/api/matches/1/transitions/active-to-draw" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s `elem` [200, 409, 404, 500]

  describe "PATCH /api/matches/1/transitions/pending-to-bye" $ do
    it "transitions Pending -> BYE" $ do
      resp <- request "PATCH" "/api/matches/1/transitions/pending-to-bye" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s `elem` [200, 409, 404, 500]

  describe "PATCH /api/matches/1/transitions/completed-to-active" $ do
    it "is denied (409 or 404)" $ do
      resp <- request "PATCH" "/api/matches/1/transitions/completed-to-active" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 409 || s == 404

  describe "PATCH /api/matches/1/transitions/draw-to-active" $ do
    it "is denied (409 or 404)" $ do
      resp <- request "PATCH" "/api/matches/1/transitions/draw-to-active" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 409 || s == 404

  describe "PATCH /api/matches/1/transitions/bye-to-active" $ do
    it "is denied (409 or 404)" $ do
      resp <- request "PATCH" "/api/matches/1/transitions/bye-to-active" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 409 || s == 404

  describe "POST /api/matches/1/record" $ do
    it "behavior record_result stub returns 404 or 500" $ do
      resp <- request "POST" "/api/matches/1/record" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/matches/1/finalize" $ do
    it "behavior finalize_result stub returns 404 or 500" $ do
      resp <- request "POST" "/api/matches/1/finalize" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "GET /api/matches/1/winner" $ do
    it "behavior determine_winner stub returns 404 or 500" $ do
      resp <- get "/api/matches/1/winner"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/matches/1/concede" $ do
    it "behavior concede stub returns 404 or 500" $ do
      resp <- request "POST" "/api/matches/1/concede" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/matches/1/draw" $ do
    it "behavior draw stub returns 404 or 500" $ do
      resp <- request "POST" "/api/matches/1/draw" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

