{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.TradelistingHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.Wai (Application)
import Data.Aeson (encode, object, (.=))
import CardsProject.App (app)
import CardsProject.Marketplace.Types

spec :: SpecWith Application
spec = do
  describe "GET /api/tradelistings" $ do
    it "returns 200" $ do
      get "/api/tradelistings" `shouldRespondWith` 200

  describe "POST /api/tradelistings" $ do
    it "creates and returns 201" $ do
      let body = encode (object ["listingType" .= ("FixedPrice"), "askingPrice" .= ("1.00"), "auctionStartPrice" .= ("1.00"), "auctionCurrentBid" .= ("1.00"), "auctionEndTime" .= ("2024-01-01T00:00:00"), "foil" .= (true), "condition" .= ("Mint"), "quantity" .= (0), "status" .= ("Active"), "description" .= ("test"), "createdAt" .= ("2024-01-01T00:00:00"), "expiresAt" .= ("2024-01-01T00:00:00"), "sellerId" .= ("test"), "cardId" .= ("test"), "bidsId" .= ("test")])
      request "POST" "/api/tradelistings" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/tradelistings/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/tradelistings/1"
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/tradelistings/1" $ do
    it "returns 200 or 404" $ do
      let body = encode (object ["listingType" .= ("FixedPrice"), "askingPrice" .= ("1.00"), "auctionStartPrice" .= ("1.00"), "auctionCurrentBid" .= ("1.00"), "auctionEndTime" .= ("2024-01-01T00:00:00"), "foil" .= (true), "condition" .= ("Mint"), "quantity" .= (0), "status" .= ("Active"), "description" .= ("test"), "createdAt" .= ("2024-01-01T00:00:00"), "expiresAt" .= ("2024-01-01T00:00:00"), "sellerId" .= ("test"), "cardId" .= ("test"), "bidsId" .= ("test")])
      resp <- request "PUT" "/api/tradelistings/1" [("Content-Type","application/json")] body
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/tradelistings/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/tradelistings/1" [] ""
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 204 || s == 404

