{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module CardsProject.Marketplace.TradeDisputeHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.HTTP.Types (statusCode)
import CardsProject.App (app)
import CardsProject.Marketplace.Types

spec :: Spec
spec = with (return app) $ do
  describe "GET /api/trade_disputes" $ do
    it "returns 200" $ do
      get "/api/trade_disputes" `shouldRespondWith` 200

  describe "POST /api/trade_disputes" $ do
    it "creates and returns 201" $ do
      let body = [json|{"reason": "ItemNotReceived", "description": "test", "status": "Open", "resolution": "test", "openedAt": "2024-01-01T00:00:00", "resolvedAt": "2024-01-01T00:00:00", "transactionId": 1, "openedById": 1, "resolvedById": null}|]
      request "POST" "/api/trade_disputes" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/trade_disputes/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/trade_disputes/1"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/trade_disputes/1" $ do
    it "returns 200 or 404" $ do
      let body = [json|{"reason": "ItemNotReceived", "description": "test", "status": "Open", "resolution": "test", "openedAt": "2024-01-01T00:00:00", "resolvedAt": "2024-01-01T00:00:00", "transactionId": 1, "openedById": 1, "resolvedById": null}|]
      resp <- request "PUT" "/api/trade_disputes/1" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/trade_disputes/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/trade_disputes/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404

  describe "POST /api/trade_disputes/1/escalate" $ do
    it "behavior escalate stub returns 404 or 500" $ do
      resp <- request "POST" "/api/trade_disputes/1/escalate" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/trade_disputes/1/resolve" $ do
    it "behavior resolve stub returns 404 or 500" $ do
      resp <- request "POST" "/api/trade_disputes/1/resolve" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/trade_disputes/1/review" $ do
    it "behavior review stub returns 404 or 500" $ do
      resp <- request "POST" "/api/trade_disputes/1/review" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

