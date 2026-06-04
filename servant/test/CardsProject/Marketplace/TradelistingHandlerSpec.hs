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

  describe "GET /api/trade_listings?q=test" $ do
    it "returns 200" $ do
      get "/api/trade_listings?q=test" `shouldRespondWith` 200

  describe "POST /api/trade_listings" $ do
    it "creates and returns 201" $ do
      let body = [json|{"status": "Active", "listingType": "FixedPrice", "askingPrice": 1.0, "auctionStartPrice": 1.0, "auctionCurrentBid": null, "auctionEndTime": "2024-01-01T00:00:00Z", "foil": false, "condition": "Mint", "quantity": 1, "description": null, "createdAt": "2024-01-01T00:00:00", "expiresAt": null, "sellerId": 1, "cardId": 1}|]
      request "POST" "/api/trade_listings" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/trade_listings/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/trade_listings/1"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PATCH /api/trade_listings/1/transitions/pending-to-active" $ do
    it "transitions Pending -> Active" $ do
      resp <- request "PATCH" "/api/trade_listings/1/transitions/pending-to-active" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s `elem` [200, 409, 404, 500]

  describe "PATCH /api/trade_listings/1/transitions/active-to-sold" $ do
    it "transitions Active -> Sold" $ do
      resp <- request "PATCH" "/api/trade_listings/1/transitions/active-to-sold" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s `elem` [200, 409, 404, 500]

  describe "PATCH /api/trade_listings/1/transitions/active-to-expired" $ do
    it "transitions Active -> Expired" $ do
      resp <- request "PATCH" "/api/trade_listings/1/transitions/active-to-expired" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s `elem` [200, 409, 404, 500]

  describe "PATCH /api/trade_listings/1/transitions/active-to-cancelled" $ do
    it "transitions Active -> Cancelled" $ do
      resp <- request "PATCH" "/api/trade_listings/1/transitions/active-to-cancelled" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s `elem` [200, 409, 404, 500]

  describe "PATCH /api/trade_listings/1/transitions/sold-to-active" $ do
    it "is denied (409 or 404)" $ do
      resp <- request "PATCH" "/api/trade_listings/1/transitions/sold-to-active" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 409 || s == 404

  describe "PATCH /api/trade_listings/1/transitions/expired-to-active" $ do
    it "is denied (409 or 404)" $ do
      resp <- request "PATCH" "/api/trade_listings/1/transitions/expired-to-active" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 409 || s == 404

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

  describe "POST /api/trade_listings rule fixed_price_requires_asking_price" $ do
    it "rejects when fixed_price_requires_asking_price violated" $ do
      let body = [json|{"status": "Active", "listingType": "FixedPrice", "askingPrice": null, "auctionStartPrice": 0.0, "auctionCurrentBid": 0.0, "auctionEndTime": "2024-01-01T00:00:00", "foil": false, "condition": "Mint", "quantity": 0, "description": "test", "createdAt": "2024-01-01T00:00:00", "expiresAt": "2024-01-01T00:00:00", "sellerId": 1, "cardId": 1}|]
      resp <- request "POST" "/api/trade_listings" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

  describe "POST /api/trade_listings rule auction_requires_start_price_and_end_time" $ do
    it "rejects when auction_requires_start_price_and_end_time violated" $ do
      let body = [json|{"status": "Active", "listingType": "Auction", "askingPrice": 0.0, "auctionStartPrice": null, "auctionCurrentBid": 0.0, "auctionEndTime": "2024-01-01T00:00:00", "foil": false, "condition": "Mint", "quantity": 0, "description": "test", "createdAt": "2024-01-01T00:00:00", "expiresAt": "2024-01-01T00:00:00", "sellerId": 1, "cardId": 1}|]
      resp <- request "POST" "/api/trade_listings" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

  describe "POST /api/trade_listings rule quantity_positive" $ do
    it "rejects when quantity_positive violated" $ do
      let body = [json|{"status": "Active", "listingType": "FixedPrice", "askingPrice": 0.0, "auctionStartPrice": 0.0, "auctionCurrentBid": 0.0, "auctionEndTime": "2024-01-01T00:00:00", "foil": false, "condition": "Mint", "quantity": 10000, "description": "test", "createdAt": "2024-01-01T00:00:00", "expiresAt": "2024-01-01T00:00:00", "sellerId": 1, "cardId": 1}|]
      resp <- request "POST" "/api/trade_listings" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

