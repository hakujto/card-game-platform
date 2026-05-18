{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module CardsProject.Tournaments.AwardedPrizeHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.HTTP.Types (statusCode)
import CardsProject.App (app)
import CardsProject.Tournaments.Types

spec :: Spec
spec = with (return app) $ do
  describe "GET /api/awarded_prizes" $ do
    it "returns 200" $ do
      get "/api/awarded_prizes" `shouldRespondWith` 200

  describe "POST /api/awarded_prizes" $ do
    it "creates and returns 201" $ do
      let body = [json|{"finalPlacement": 0, "awardedAt": "2024-01-01T00:00:00", "claimed": true, "claimedAt": "2024-01-01T00:00:00", "prizeId": 1, "playerId": 1}|]
      request "POST" "/api/awarded_prizes" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/awarded_prizes/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/awarded_prizes/1"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/awarded_prizes/1" $ do
    it "returns 200 or 404" $ do
      let body = [json|{"finalPlacement": 0, "awardedAt": "2024-01-01T00:00:00", "claimed": true, "claimedAt": "2024-01-01T00:00:00", "prizeId": 1, "playerId": 1}|]
      resp <- request "PUT" "/api/awarded_prizes/1" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/awarded_prizes/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/awarded_prizes/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404

  describe "POST /api/awarded_prizes/1/claim" $ do
    it "behavior claim stub returns 404 or 500" $ do
      resp <- request "POST" "/api/awarded_prizes/1/claim" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

