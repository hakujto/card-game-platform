{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.TradeBidHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.Wai (Application)
import Data.Aeson (encode, object, (.=))
import CardsProject.App (app)
import CardsProject.Marketplace.Types

spec :: SpecWith Application
spec = do
  describe "GET /api/trade_bids" $ do
    it "returns 200" $ do
      get "/api/trade_bids" `shouldRespondWith` 200

  describe "POST /api/trade_bids" $ do
    it "creates and returns 201" $ do
      let body = encode (object ["amount" .= ("1.00"), "placedAt" .= ("2024-01-01T00:00:00"), "isWinning" .= (true), "listingId" .= ("test"), "bidderId" .= ("test")])
      request "POST" "/api/trade_bids" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/trade_bids/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/trade_bids/1"
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/trade_bids/1" $ do
    it "returns 200 or 404" $ do
      let body = encode (object ["amount" .= ("1.00"), "placedAt" .= ("2024-01-01T00:00:00"), "isWinning" .= (true), "listingId" .= ("test"), "bidderId" .= ("test")])
      resp <- request "PUT" "/api/trade_bids/1" [("Content-Type","application/json")] body
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/trade_bids/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/trade_bids/1" [] ""
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 204 || s == 404

