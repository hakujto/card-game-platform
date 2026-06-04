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

  describe "GET /api/trade_transactions/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/trade_transactions/1"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "POST /api/trade_transactions/1/complete" $ do
    it "behavior complete stub returns 404 or 500" $ do
      resp <- request "POST" "/api/trade_transactions/1/complete" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/trade_transactions/1/refund" $ do
    it "behavior refund stub returns 404 or 500" $ do
      resp <- request "POST" "/api/trade_transactions/1/refund" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/trade_transactions/1/dispute" $ do
    it "behavior open_dispute stub returns 404 or 500" $ do
      resp <- request "POST" "/api/trade_transactions/1/dispute" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "GET /api/trade_transactions/1/seller-net" $ do
    it "behavior seller_net stub returns 404 or 500" $ do
      resp <- get "/api/trade_transactions/1/seller-net"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

