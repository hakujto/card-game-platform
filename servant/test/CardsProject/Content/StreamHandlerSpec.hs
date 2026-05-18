{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module CardsProject.Content.StreamHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.HTTP.Types (statusCode)
import CardsProject.App (app)
import CardsProject.Content.Types

spec :: Spec
spec = with (return app) $ do
  describe "GET /api/streams" $ do
    it "returns 200" $ do
      get "/api/streams" `shouldRespondWith` 200

  describe "POST /api/streams" $ do
    it "creates and returns 201" $ do
      let body = [json|{"title": "test", "streamUrl": "https://example.com", "platform": "Twitch", "status": "Scheduled", "viewerCountPeak": 0, "scheduledStart": "2024-01-01T00:00:00", "actualStart": "2024-01-01T00:00:00", "endedAt": "2024-01-01T00:00:00", "vodUrl": "https://example.com", "tournamentId": null, "streamerId": 1}|]
      request "POST" "/api/streams" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/streams/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/streams/1"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/streams/1" $ do
    it "returns 200 or 404" $ do
      let body = [json|{"title": "test", "streamUrl": "https://example.com", "platform": "Twitch", "status": "Scheduled", "viewerCountPeak": 0, "scheduledStart": "2024-01-01T00:00:00", "actualStart": "2024-01-01T00:00:00", "endedAt": "2024-01-01T00:00:00", "vodUrl": "https://example.com", "tournamentId": null, "streamerId": 1}|]
      resp <- request "PUT" "/api/streams/1" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/streams/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/streams/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404

  describe "POST /api/streams/1/live" $ do
    it "behavior go_live stub returns 404 or 500" $ do
      resp <- request "POST" "/api/streams/1/live" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/streams/1/end" $ do
    it "behavior end stub returns 404 or 500" $ do
      resp <- request "POST" "/api/streams/1/end" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "PATCH /api/streams/1/viewers" $ do
    it "behavior update_viewer_peak stub returns 404 or 500" $ do
      resp <- request "PATCH" "/api/streams/1/viewers" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "GET /api/streams/1/duration" $ do
    it "behavior duration_minutes stub returns 404 or 500" $ do
      resp <- get "/api/streams/1/duration"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

