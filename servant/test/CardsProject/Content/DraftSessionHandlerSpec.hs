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
      let body = [json|{"status": "WaitingForPlayers", "draftType": "Booster", "seats": 0, "createdAt": "2024-01-01T00:00:00", "completedAt": "2024-01-01T00:00:00", "cardSetId": 1, "participantsId": 1}|]
      request "POST" "/api/draft_sessions" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/draft_sessions/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/draft_sessions/1"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/draft_sessions/1" $ do
    it "returns 200 or 404" $ do
      let body = [json|{"status": "WaitingForPlayers", "draftType": "Booster", "seats": 0, "createdAt": "2024-01-01T00:00:00", "completedAt": "2024-01-01T00:00:00", "cardSetId": 1, "participantsId": 1}|]
      resp <- request "PUT" "/api/draft_sessions/1" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/draft_sessions/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/draft_sessions/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404

  describe "POST /api/draft_sessions/1/start" $ do
    it "behavior start stub returns 404 or 500" $ do
      resp <- request "POST" "/api/draft_sessions/1/start" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 404 || s == 500

  describe "POST /api/draft_sessions/1/abandon" $ do
    it "behavior abandon stub returns 404 or 500" $ do
      resp <- request "POST" "/api/draft_sessions/1/abandon" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 404 || s == 500

  describe "POST /api/draft_sessions/1/complete" $ do
    it "behavior complete stub returns 404 or 500" $ do
      resp <- request "POST" "/api/draft_sessions/1/complete" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 404 || s == 500

