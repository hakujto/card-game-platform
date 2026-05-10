{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.TradeDisputeHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.Wai (Application)
import Data.Aeson (encode, object, (.=))
import CardsProject.App (app)
import CardsProject.Marketplace.Types

spec :: SpecWith Application
spec = do
  describe "GET /api/trade_disputes" $ do
    it "returns 200" $ do
      get "/api/trade_disputes" `shouldRespondWith` 200

  describe "POST /api/trade_disputes" $ do
    it "creates and returns 201" $ do
      let body = encode (object ["reason" .= ("ItemNotReceived"), "description" .= ("test"), "status" .= ("Open"), "resolution" .= ("test"), "openedAt" .= ("2024-01-01T00:00:00"), "resolvedAt" .= ("2024-01-01T00:00:00"), "transactionId" .= ("test"), "openedById" .= ("test"), "resolvedById" .= ("test")])
      request "POST" "/api/trade_disputes" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/trade_disputes/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/trade_disputes/1"
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/trade_disputes/1" $ do
    it "returns 200 or 404" $ do
      let body = encode (object ["reason" .= ("ItemNotReceived"), "description" .= ("test"), "status" .= ("Open"), "resolution" .= ("test"), "openedAt" .= ("2024-01-01T00:00:00"), "resolvedAt" .= ("2024-01-01T00:00:00"), "transactionId" .= ("test"), "openedById" .= ("test"), "resolvedById" .= ("test")])
      resp <- request "PUT" "/api/trade_disputes/1" [("Content-Type","application/json")] body
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/trade_disputes/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/trade_disputes/1" [] ""
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 204 || s == 404

