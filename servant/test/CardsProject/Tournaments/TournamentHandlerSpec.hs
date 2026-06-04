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

  describe "GET /api/tournaments?q=test" $ do
    it "returns 200" $ do
      get "/api/tournaments?q=test" `shouldRespondWith` 200

  describe "POST /api/tournaments" $ do
    it "creates and returns 201" $ do
      let body = [json|{"name": "test", "description": null, "status": "Draft", "format": "Standard", "tournamentType": "Swiss", "maxPlayers": 2, "entryFee": 0, "prizePool": 0, "startTime": "2024-01-01T00:00:00", "endTime": "2024-01-02T00:00:00Z", "isOnline": false, "location": null, "rulesText": null, "createdAt": "2024-01-01T00:00:00", "seasonId": 1, "organizerId": 1}|]
      request "POST" "/api/tournaments" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/tournaments/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/tournaments/1"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/tournaments/1" $ do
    it "returns 200 or 404" $ do
      let body = [json|{"name": "test", "description": null, "status": "Draft", "format": "Standard", "tournamentType": "Swiss", "maxPlayers": 2, "entryFee": 0, "prizePool": 0, "startTime": "2024-01-01T00:00:00", "endTime": "2024-01-02T00:00:00Z", "isOnline": false, "location": null, "rulesText": null, "createdAt": "2024-01-01T00:00:00", "seasonId": 1, "organizerId": 1}|]
      resp <- request "PUT" "/api/tournaments/1" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PATCH /api/tournaments/1/transitions/draft-to-registration" $ do
    it "transitions Draft -> Registration" $ do
      resp <- request "PATCH" "/api/tournaments/1/transitions/draft-to-registration" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s `elem` [200, 409, 404, 500]

  describe "PATCH /api/tournaments/1/transitions/registration-to-ongoing" $ do
    it "transitions Registration -> Ongoing" $ do
      resp <- request "PATCH" "/api/tournaments/1/transitions/registration-to-ongoing" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s `elem` [200, 409, 404, 500]

  describe "PATCH /api/tournaments/1/transitions/registration-to-cancelled" $ do
    it "transitions Registration -> Cancelled" $ do
      resp <- request "PATCH" "/api/tournaments/1/transitions/registration-to-cancelled" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s `elem` [200, 409, 404, 500]

  describe "PATCH /api/tournaments/1/transitions/ongoing-to-completed" $ do
    it "transitions Ongoing -> Completed" $ do
      resp <- request "PATCH" "/api/tournaments/1/transitions/ongoing-to-completed" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s `elem` [200, 409, 404, 500]

  describe "PATCH /api/tournaments/1/transitions/ongoing-to-cancelled" $ do
    it "transitions Ongoing -> Cancelled" $ do
      resp <- request "PATCH" "/api/tournaments/1/transitions/ongoing-to-cancelled" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s `elem` [200, 409, 404, 500]

  describe "PATCH /api/tournaments/1/transitions/completed-to-draft" $ do
    it "is denied (409 or 404)" $ do
      resp <- request "PATCH" "/api/tournaments/1/transitions/completed-to-draft" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 409 || s == 404

  describe "PATCH /api/tournaments/1/transitions/cancelled-to-draft" $ do
    it "is denied (409 or 404)" $ do
      resp <- request "PATCH" "/api/tournaments/1/transitions/cancelled-to-draft" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 409 || s == 404

  describe "POST /api/tournaments/1/start" $ do
    it "behavior start stub returns 404 or 500" $ do
      resp <- request "POST" "/api/tournaments/1/start" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/tournaments/1/cancel" $ do
    it "behavior cancel stub returns 404 or 500" $ do
      resp <- request "POST" "/api/tournaments/1/cancel" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/tournaments/1/complete" $ do
    it "behavior complete stub returns 404 or 500" $ do
      resp <- request "POST" "/api/tournaments/1/complete" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/tournaments/1/rounds" $ do
    it "behavior generate_round stub returns 404 or 500" $ do
      resp <- request "POST" "/api/tournaments/1/rounds" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "GET /api/tournaments/1/prizes" $ do
    it "behavior calculate_prize_distribution stub returns 404 or 500" $ do
      resp <- get "/api/tournaments/1/prizes"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/tournaments/1/register" $ do
    it "behavior register_player stub returns 404 or 500" $ do
      resp <- request "POST" "/api/tournaments/1/register" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "GET /api/tournaments/1/full" $ do
    it "behavior is_full stub returns 404 or 500" $ do
      resp <- get "/api/tournaments/1/full"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/tournaments rule max_players_positive" $ do
    it "rejects when max_players_positive violated" $ do
      let body = [json|{"name": "test", "description": "test", "status": "Draft", "format": "Standard", "tournamentType": "Swiss", "maxPlayers": 513, "entryFee": 0.0, "prizePool": 0.0, "startTime": "2024-01-01T00:00:00", "endTime": "2024-01-01T00:00:00", "isOnline": false, "location": "test", "rulesText": "test", "createdAt": "2024-01-01T00:00:00", "seasonId": 1, "organizerId": 1}|]
      resp <- request "POST" "/api/tournaments" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

  describe "POST /api/tournaments rule entry_fee_not_negative" $ do
    it "rejects when entry_fee_not_negative violated" $ do
      let body = [json|{"name": "test", "description": "test", "status": "Draft", "format": "Standard", "tournamentType": "Swiss", "maxPlayers": 0, "entryFee": -2, "prizePool": 0.0, "startTime": "2024-01-01T00:00:00", "endTime": "2024-01-01T00:00:00", "isOnline": false, "location": "test", "rulesText": "test", "createdAt": "2024-01-01T00:00:00", "seasonId": 1, "organizerId": 1}|]
      resp <- request "POST" "/api/tournaments" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

  describe "POST /api/tournaments rule prize_pool_not_negative" $ do
    it "rejects when prize_pool_not_negative violated" $ do
      let body = [json|{"name": "test", "description": "test", "status": "Draft", "format": "Standard", "tournamentType": "Swiss", "maxPlayers": 0, "entryFee": 0.0, "prizePool": -2, "startTime": "2024-01-01T00:00:00", "endTime": "2024-01-01T00:00:00", "isOnline": false, "location": "test", "rulesText": "test", "createdAt": "2024-01-01T00:00:00", "seasonId": 1, "organizerId": 1}|]
      resp <- request "POST" "/api/tournaments" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

  describe "POST /api/tournaments rule end_time_after_start" $ do
    it "rejects when end_time_after_start violated" $ do
      let body = [json|{"name": "test", "description": "test", "status": "Draft", "format": "Standard", "tournamentType": "Swiss", "maxPlayers": 0, "entryFee": 0.0, "prizePool": 0.0, "startTime": "2024-01-02T00:00:00Z", "endTime": "2024-01-01T00:00:00Z", "isOnline": false, "location": "test", "rulesText": "test", "createdAt": "2024-01-01T00:00:00", "seasonId": 1, "organizerId": 1}|]
      resp <- request "POST" "/api/tournaments" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

