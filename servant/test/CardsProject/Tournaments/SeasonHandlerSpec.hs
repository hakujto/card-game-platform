{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module CardsProject.Tournaments.SeasonHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.HTTP.Types (statusCode)
import CardsProject.App (app)
import CardsProject.Tournaments.Types

spec :: Spec
spec = with (return app) $ do
  describe "GET /api/seasons" $ do
    it "returns 200" $ do
      get "/api/seasons" `shouldRespondWith` 200

  describe "POST /api/seasons" $ do
    it "creates and returns 201" $ do
      let body = [json|{"name": "test", "startDate": "2024-01-01", "endDate": "2024-01-01", "format": "Standard", "isActive": true, "rewardDescription": "test"}|]
      request "POST" "/api/seasons" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/seasons/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/seasons/1"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/seasons/1" $ do
    it "returns 200 or 404" $ do
      let body = [json|{"name": "test", "startDate": "2024-01-01", "endDate": "2024-01-01", "format": "Standard", "isActive": true, "rewardDescription": "test"}|]
      resp <- request "PUT" "/api/seasons/1" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/seasons/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/seasons/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404

  describe "POST /api/seasons/1/activate" $ do
    it "behavior activate stub returns 404 or 500" $ do
      resp <- request "POST" "/api/seasons/1/activate" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 404 || s == 500

  describe "POST /api/seasons/1/deactivate" $ do
    it "behavior deactivate stub returns 404 or 500" $ do
      resp <- request "POST" "/api/seasons/1/deactivate" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 404 || s == 500

  describe "POST /api/seasons/1/finalize" $ do
    it "behavior finalize_rewards stub returns 404 or 500" $ do
      resp <- request "POST" "/api/seasons/1/finalize" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 404 || s == 500

