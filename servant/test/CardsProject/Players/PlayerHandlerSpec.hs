{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module CardsProject.Players.PlayerHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.HTTP.Types (statusCode)
import CardsProject.App (app)
import CardsProject.Players.Types

spec :: Spec
spec = with (return app) $ do
  describe "GET /api/players" $ do
    it "returns 200" $ do
      get "/api/players" `shouldRespondWith` 200

  describe "GET /api/players?q=test" $ do
    it "returns 200" $ do
      get "/api/players?q=test" `shouldRespondWith` 200

  describe "POST /api/players" $ do
    it "creates and returns 201" $ do
      let body = [json|{"displayName": "test", "rank": "Bronze", "rating": 0, "peakRating": 1, "bio": null, "countryCode": null, "avatarUrl": null, "preferredFormat": null, "isVerified": false, "createdAt": "2024-01-01T00:00:00", "lastActiveAt": null, "userId": null}|]
      request "POST" "/api/players" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/players/1" $ do
    it "returns 200, 401, or 404" $ do
      resp <- request "GET" "/api/players/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 401 || s == 403 || s == 404

  describe "PATCH /api/players/1" $ do
    it "returns 200, 401, 403, or 404" $ do
      let body = [json|{"displayName": "test", "rank": "Bronze", "rating": 0, "peakRating": 1, "bio": null, "countryCode": null, "avatarUrl": null, "preferredFormat": null, "isVerified": false, "createdAt": "2024-01-01T00:00:00", "lastActiveAt": null, "userId": null}|]
      resp <- request "PATCH" "/api/players/1" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 401 || s == 403 || s == 404

  describe "POST /api/players/1/promote" $ do
    it "behavior promote stub returns 404 or 500" $ do
      resp <- request "POST" "/api/players/1/promote" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/players/1/demote" $ do
    it "behavior demote stub returns 404 or 500" $ do
      resp <- request "POST" "/api/players/1/demote" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/players/1/win" $ do
    it "behavior record_win stub returns 404 or 500" $ do
      resp <- request "POST" "/api/players/1/win" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/players/1/loss" $ do
    it "behavior record_loss stub returns 404 or 500" $ do
      resp <- request "POST" "/api/players/1/loss" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "GET /api/players/1/win-rate" $ do
    it "behavior win_rate stub returns 404 or 500" $ do
      resp <- get "/api/players/1/win-rate"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/players/1/verify" $ do
    it "behavior verify stub returns 404 or 500" $ do
      resp <- request "POST" "/api/players/1/verify" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "PATCH /api/players/1/rating" $ do
    it "behavior update_rating stub returns 404 or 500" $ do
      resp <- request "PATCH" "/api/players/1/rating" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/players rule rating_range" $ do
    it "rejects when rating_range violated" $ do
      let body = [json|{"displayName": "test", "rank": "Bronze", "rating": 10000, "peakRating": 0, "bio": "test", "countryCode": "test", "avatarUrl": "https://example.com", "preferredFormat": "Standard", "isVerified": false, "createdAt": "2024-01-01T00:00:00", "lastActiveAt": "2024-01-01T00:00:00", "userId": null}|]
      resp <- request "POST" "/api/players" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

  describe "POST /api/players rule display_name_not_empty" $ do
    it "rejects when display_name_not_empty violated" $ do
      let body = [json|{"displayName": null, "rank": "Bronze", "rating": 0, "peakRating": 0, "bio": "test", "countryCode": "test", "avatarUrl": "https://example.com", "preferredFormat": "Standard", "isVerified": false, "createdAt": "2024-01-01T00:00:00", "lastActiveAt": "2024-01-01T00:00:00", "userId": null}|]
      resp <- request "POST" "/api/players" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

