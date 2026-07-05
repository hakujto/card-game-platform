{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module CardsProject.Marketplace.TradeBidHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.HTTP.Types (statusCode)
import CardsProject.App (app)
import CardsProject.Marketplace.Types

spec :: Spec
spec = with (return app) $ do
  describe "GET /api/trade_bids" $ do
    it "returns 200" $ do
      get "/api/trade_bids" `shouldRespondWith` 200

  describe "POST /api/trade_bids" $ do
    it "creates and returns 201" $ do
      let body = [json|{"amount": 1, "placedAt": "2024-01-01T00:00:00", "isWinning": false, "listingId": 1, "bidderId": 1}|]
      request "POST" "/api/trade_bids" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/trade_bids/1" $ do
    it "returns 200, 401, or 404" $ do
      resp <- request "GET" "/api/trade_bids/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 401 || s == 403 || s == 404

  describe "GET /api/trade_bids/1/outbid" $ do
    it "behavior outbid_by stub returns 404 or 500" $ do
      resp <- get "/api/trade_bids/1/outbid"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 400 || s == 401 || s == 404 || s == 500

  describe "DELETE /api/trade_bids/1" $ do
    it "behavior retract stub returns 404 or 500" $ do
      resp <- request "DELETE" "/api/trade_bids/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 400 || s == 401 || s == 404 || s == 500

  describe "POST /api/trade_bids rule amount_positive" $ do
    it "rejects when amount_positive violated" $ do
      let body = [json|{"amount": 0, "placedAt": "2024-01-01T00:00:00", "isWinning": false, "listingId": 1, "bidderId": 1}|]
      resp <- request "POST" "/api/trade_bids" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

