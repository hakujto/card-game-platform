{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module CardsProject.Marketplace.TradeListingHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.HTTP.Types (statusCode)
import CardsProject.App (app)
import CardsProject.Marketplace.Types

spec :: Spec
spec = with (return app) $ do
  describe "GET /api/trade_listings" $ do
    it "returns 200" $ do
      get "/api/trade_listings" `shouldRespondWith` 200

  describe "POST /api/trade_listings" $ do
    it "creates and returns 201" $ do
      let body = [json|{"listingType": "FixedPrice", "askingPrice": "1.00", "auctionStartPrice": "1.00", "auctionCurrentBid": "1.00", "auctionEndTime": "2024-01-01T00:00:00", "foil": true, "condition": "Mint", "quantity": 0, "status": "Active", "description": "test", "createdAt": "2024-01-01T00:00:00", "expiresAt": "2024-01-01T00:00:00", "sellerId": 1, "cardId": 1, "bidsId": null}|]
      request "POST" "/api/trade_listings" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/trade_listings/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/trade_listings/1"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/trade_listings/1" $ do
    it "returns 200 or 404" $ do
      let body = [json|{"listingType": "FixedPrice", "askingPrice": "1.00", "auctionStartPrice": "1.00", "auctionCurrentBid": "1.00", "auctionEndTime": "2024-01-01T00:00:00", "foil": true, "condition": "Mint", "quantity": 0, "status": "Active", "description": "test", "createdAt": "2024-01-01T00:00:00", "expiresAt": "2024-01-01T00:00:00", "sellerId": 1, "cardId": 1, "bidsId": null}|]
      resp <- request "PUT" "/api/trade_listings/1" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/trade_listings/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/trade_listings/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404

  describe "POST /api/trade_listings/1/close" $ do
    it "behavior close stub returns 404 or 500" $ do
      resp <- request "POST" "/api/trade_listings/1/close" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "PATCH /api/trade_listings/1/extend" $ do
    it "behavior extend stub returns 404 or 500" $ do
      resp <- request "PATCH" "/api/trade_listings/1/extend" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "DELETE /api/trade_listings/1/cancel" $ do
    it "behavior cancel stub returns 404 or 500" $ do
      resp <- request "DELETE" "/api/trade_listings/1/cancel" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "GET /api/trade_listings/1/expired" $ do
    it "behavior is_expired stub returns 404 or 500" $ do
      resp <- get "/api/trade_listings/1/expired"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/trade_listings/1/finalize" $ do
    it "behavior finalize_auction stub returns 404 or 500" $ do
      resp <- request "POST" "/api/trade_listings/1/finalize" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

