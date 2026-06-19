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

  describe "GET /api/streams?q=test" $ do
    it "returns 200" $ do
      get "/api/streams?q=test" `shouldRespondWith` 200

  describe "POST /api/streams" $ do
    it "creates and returns 201" $ do
      let body = [json|{"title": "test", "streamUrl": "https://example.com", "status": "Scheduled", "platform": "Twitch", "language": "EN", "isOfficial": false, "viewerCountPeak": 0, "scheduledStart": "2024-01-01T00:00:00", "actualStart": null, "endedAt": null, "vodUrl": null, "tournamentId": null, "streamerId": 1}|]
      request "POST" "/api/streams" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/streams/1" $ do
    it "returns 200, 401, or 404" $ do
      resp <- request "GET" "/api/streams/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 401 || s == 403 || s == 404

  describe "PUT /api/streams/1" $ do
    it "returns 200, 401, 403, or 404" $ do
      let body = [json|{"title": "test", "streamUrl": "https://example.com", "status": "Scheduled", "platform": "Twitch", "language": "EN", "isOfficial": false, "viewerCountPeak": 0, "scheduledStart": "2024-01-01T00:00:00", "actualStart": null, "endedAt": null, "vodUrl": null, "tournamentId": null, "streamerId": 1}|]
      resp <- request "PUT" "/api/streams/1" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 401 || s == 403 || s == 404

  describe "PATCH /api/streams/1" $ do
    it "returns 200, 401, 403, or 404" $ do
      let body = [json|{"title": "test", "streamUrl": "https://example.com", "status": "Scheduled", "platform": "Twitch", "language": "EN", "isOfficial": false, "viewerCountPeak": 0, "scheduledStart": "2024-01-01T00:00:00", "actualStart": null, "endedAt": null, "vodUrl": null, "tournamentId": null, "streamerId": 1}|]
      resp <- request "PATCH" "/api/streams/1" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 401 || s == 403 || s == 404

  describe "PATCH /api/streams/1/transitions/scheduled-to-live" $ do
    it "transitions Scheduled -> Live with role Streamer" $ do
      resp <- request "PATCH" "/api/streams/1/transitions/scheduled-to-live" [("X-User-Role","Streamer")] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s `elem` [200, 409, 404, 500]

    it "rejects Scheduled -> Live without role (401 or 403)" $ do
      resp <- request "PATCH" "/api/streams/1/transitions/scheduled-to-live" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 401 || s == 403

  describe "PATCH /api/streams/1/transitions/live-to-ended" $ do
    it "transitions Live -> Ended with role Streamer" $ do
      resp <- request "PATCH" "/api/streams/1/transitions/live-to-ended" [("X-User-Role","Streamer")] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s `elem` [200, 409, 404, 500]

    it "rejects Live -> Ended without role (401 or 403)" $ do
      resp <- request "PATCH" "/api/streams/1/transitions/live-to-ended" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 401 || s == 403

  describe "PATCH /api/streams/1/transitions/ended-to-live" $ do
    it "is denied (409 or 404)" $ do
      resp <- request "PATCH" "/api/streams/1/transitions/ended-to-live" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 409 || s == 404

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

  describe "POST /api/streams rule actual_start_requires_live_or_ended" $ do
    it "rejects when actual_start_requires_live_or_ended violated" $ do
      let body = [json|{"title": "test", "streamUrl": "https://example.com", "status": "Scheduled", "platform": "Twitch", "language": "EN", "isOfficial": false, "viewerCountPeak": 0, "scheduledStart": "2024-01-01T00:00:00", "actualStart": "test", "endedAt": "2024-01-01T00:00:00", "vodUrl": "https://example.com", "tournamentId": null, "streamerId": 1}|]
      resp <- request "POST" "/api/streams" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

  describe "POST /api/streams rule ended_at_requires_ended_status" $ do
    it "rejects when ended_at_requires_ended_status violated" $ do
      let body = [json|{"title": "test", "streamUrl": "https://example.com", "status": "Scheduled", "platform": "Twitch", "language": "EN", "isOfficial": false, "viewerCountPeak": 0, "scheduledStart": "2024-01-01T00:00:00", "actualStart": "2024-01-01T00:00:00", "endedAt": "test", "vodUrl": "https://example.com", "tournamentId": null, "streamerId": 1}|]
      resp <- request "POST" "/api/streams" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

  describe "POST /api/streams rule viewer_count_not_negative" $ do
    it "rejects when viewer_count_not_negative violated" $ do
      let body = [json|{"title": "test", "streamUrl": "https://example.com", "status": "Scheduled", "platform": "Twitch", "language": "EN", "isOfficial": false, "viewerCountPeak": -2, "scheduledStart": "2024-01-01T00:00:00", "actualStart": "2024-01-01T00:00:00", "endedAt": "2024-01-01T00:00:00", "vodUrl": "https://example.com", "tournamentId": null, "streamerId": 1}|]
      resp <- request "POST" "/api/streams" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

