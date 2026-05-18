{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module CardsProject.Marketplace.TradeTransactionHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.HTTP.Types (statusCode)
import CardsProject.App (app)
import CardsProject.Marketplace.Types

spec :: Spec
spec = with (return app) $ do
  describe "GET /api/trade_transactions" $ do
    it "returns 200" $ do
      get "/api/trade_transactions" `shouldRespondWith` 200

  describe "POST /api/trade_transactions" $ do
    it "creates and returns 201" $ do
      let body = [json|{"finalPrice": "1.00", "platformFee": "1.00", "status": "Pending", "completedAt": "2024-01-01T00:00:00", "listingId": 1, "buyerId": 1, "sellerId": 1}|]
      request "POST" "/api/trade_transactions" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/trade_transactions/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/trade_transactions/1"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/trade_transactions/1" $ do
    it "returns 200 or 404" $ do
      let body = [json|{"finalPrice": "1.00", "platformFee": "1.00", "status": "Pending", "completedAt": "2024-01-01T00:00:00", "listingId": 1, "buyerId": 1, "sellerId": 1}|]
      resp <- request "PUT" "/api/trade_transactions/1" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/trade_transactions/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/trade_transactions/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404

  describe "POST /api/trade_transactions/1/complete" $ do
    it "behavior complete stub returns 404 or 500" $ do
      resp <- request "POST" "/api/trade_transactions/1/complete" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 404 || s == 500

  describe "POST /api/trade_transactions/1/refund" $ do
    it "behavior refund stub returns 404 or 500" $ do
      resp <- request "POST" "/api/trade_transactions/1/refund" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 404 || s == 500

  describe "POST /api/trade_transactions/1/dispute" $ do
    it "behavior open_dispute stub returns 404 or 500" $ do
      resp <- request "POST" "/api/trade_transactions/1/dispute" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 404 || s == 500

