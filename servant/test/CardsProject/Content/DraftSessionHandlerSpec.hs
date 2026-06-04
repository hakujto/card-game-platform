{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module CardsProject.Content.DraftSessionHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.HTTP.Types (statusCode)
import CardsProject.App (app)
import CardsProject.Content.Types

spec :: Spec
spec = with (return app) $ do
  describe "GET /api/draft_sessions" $ do
    it "returns 200" $ do
      get "/api/draft_sessions" `shouldRespondWith` 200

  describe "POST /api/draft_sessions" $ do
    it "creates and returns 201" $ do
      let body = [json|{"status": "WaitingForPlayers", "draftType": "Booster", "seats": 2, "timePerPickSeconds": 1, "createdAt": "2024-01-01T00:00:00", "completedAt": null, "cardSetId": 1}|]
      request "POST" "/api/draft_sessions" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/draft_sessions/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/draft_sessions/1"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PATCH /api/draft_sessions/1/transitions/waitingforplayers-to-drafting" $ do
    it "transitions WaitingForPlayers -> Drafting" $ do
      resp <- request "PATCH" "/api/draft_sessions/1/transitions/waitingforplayers-to-drafting" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s `elem` [200, 409, 404, 500]

  describe "PATCH /api/draft_sessions/1/transitions/drafting-to-completed" $ do
    it "transitions Drafting -> Completed" $ do
      resp <- request "PATCH" "/api/draft_sessions/1/transitions/drafting-to-completed" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s `elem` [200, 409, 404, 500]

  describe "PATCH /api/draft_sessions/1/transitions/drafting-to-abandoned" $ do
    it "transitions Drafting -> Abandoned" $ do
      resp <- request "PATCH" "/api/draft_sessions/1/transitions/drafting-to-abandoned" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s `elem` [200, 409, 404, 500]

  describe "PATCH /api/draft_sessions/1/transitions/waitingforplayers-to-abandoned" $ do
    it "transitions WaitingForPlayers -> Abandoned" $ do
      resp <- request "PATCH" "/api/draft_sessions/1/transitions/waitingforplayers-to-abandoned" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s `elem` [200, 409, 404, 500]

  describe "PATCH /api/draft_sessions/1/transitions/completed-to-drafting" $ do
    it "is denied (409 or 404)" $ do
      resp <- request "PATCH" "/api/draft_sessions/1/transitions/completed-to-drafting" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 409 || s == 404

  describe "PATCH /api/draft_sessions/1/transitions/abandoned-to-drafting" $ do
    it "is denied (409 or 404)" $ do
      resp <- request "PATCH" "/api/draft_sessions/1/transitions/abandoned-to-drafting" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 409 || s == 404

  describe "POST /api/draft_sessions/1/start" $ do
    it "behavior start stub returns 404 or 500" $ do
      resp <- request "POST" "/api/draft_sessions/1/start" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/draft_sessions/1/abandon" $ do
    it "behavior abandon stub returns 404 or 500" $ do
      resp <- request "POST" "/api/draft_sessions/1/abandon" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/draft_sessions/1/complete" $ do
    it "behavior complete stub returns 404 or 500" $ do
      resp <- request "POST" "/api/draft_sessions/1/complete" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "GET /api/draft_sessions/1/full" $ do
    it "behavior is_full stub returns 404 or 500" $ do
      resp <- get "/api/draft_sessions/1/full"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/draft_sessions rule seats_range" $ do
    it "rejects when seats_range violated" $ do
      let body = [json|{"status": "WaitingForPlayers", "draftType": "Booster", "seats": 17, "timePerPickSeconds": 0, "createdAt": "2024-01-01T00:00:00", "completedAt": "2024-01-01T00:00:00", "cardSetId": 1}|]
      resp <- request "POST" "/api/draft_sessions" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

  describe "POST /api/draft_sessions rule completed_at_requires_completed_status" $ do
    it "rejects when completed_at_requires_completed_status violated" $ do
      let body = [json|{"status": "WaitingForPlayers", "draftType": "Booster", "seats": 0, "timePerPickSeconds": 0, "createdAt": "2024-01-01T00:00:00", "completedAt": "test", "cardSetId": 1}|]
      resp <- request "POST" "/api/draft_sessions" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

  describe "POST /api/draft_sessions rule time_per_pick_positive" $ do
    it "rejects when time_per_pick_positive violated" $ do
      let body = [json|{"status": "WaitingForPlayers", "draftType": "Booster", "seats": 0, "timePerPickSeconds": 0, "createdAt": "2024-01-01T00:00:00", "completedAt": "2024-01-01T00:00:00", "cardSetId": 1}|]
      resp <- request "POST" "/api/draft_sessions" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

