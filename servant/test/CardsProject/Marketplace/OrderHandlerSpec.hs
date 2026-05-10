{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.OrderHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.Wai (Application)
import Data.Aeson (encode, object, (.=))
import CardsProject.App (app)
import CardsProject.Marketplace.Types

spec :: SpecWith Application
spec = do
  describe "GET /api/orders" $ do
    it "returns 200" $ do
      get "/api/orders" `shouldRespondWith` 200

  describe "POST /api/orders" $ do
    it "creates and returns 201" $ do
      let body = encode (object ["status" .= ("Pending"), "total" .= ("1.00"), "discountApplied" .= ("1.00"), "currency" .= ("test"), "paymentMethod" .= ("Card"), "paymentReference" .= ("test"), "shippingAddress" .= ("test"), "trackingNumber" .= ("test"), "createdAt" .= ("2024-01-01T00:00:00"), "paidAt" .= ("2024-01-01T00:00:00"), "shippedAt" .= ("2024-01-01T00:00:00"), "playerId" .= ("test"), "itemsId" .= ("test"), "couponId" .= ("test")])
      request "POST" "/api/orders" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/orders/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/orders/1"
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/orders/1" $ do
    it "returns 200 or 404" $ do
      let body = encode (object ["status" .= ("Pending"), "total" .= ("1.00"), "discountApplied" .= ("1.00"), "currency" .= ("test"), "paymentMethod" .= ("Card"), "paymentReference" .= ("test"), "shippingAddress" .= ("test"), "trackingNumber" .= ("test"), "createdAt" .= ("2024-01-01T00:00:00"), "paidAt" .= ("2024-01-01T00:00:00"), "shippedAt" .= ("2024-01-01T00:00:00"), "playerId" .= ("test"), "itemsId" .= ("test"), "couponId" .= ("test")])
      resp <- request "PUT" "/api/orders/1" [("Content-Type","application/json")] body
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/orders/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/orders/1" [] ""
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 204 || s == 404

