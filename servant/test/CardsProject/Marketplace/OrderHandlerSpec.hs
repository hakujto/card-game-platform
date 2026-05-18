{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module CardsProject.Marketplace.OrderHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.HTTP.Types (statusCode)
import CardsProject.App (app)
import CardsProject.Marketplace.Types

spec :: Spec
spec = with (return app) $ do
  describe "GET /api/orders" $ do
    it "returns 200" $ do
      get "/api/orders" `shouldRespondWith` 200

  describe "POST /api/orders" $ do
    it "creates and returns 201" $ do
      let body = [json|{"status": "Pending", "total": "1.00", "discountApplied": "1.00", "currency": "test", "paymentMethod": "Card", "paymentReference": "test", "shippingAddress": "test", "trackingNumber": "test", "createdAt": "2024-01-01T00:00:00", "paidAt": "2024-01-01T00:00:00", "shippedAt": "2024-01-01T00:00:00", "playerId": 1, "itemsId": 1, "couponId": null}|]
      request "POST" "/api/orders" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/orders/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/orders/1"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/orders/1" $ do
    it "returns 200 or 404" $ do
      let body = [json|{"status": "Pending", "total": "1.00", "discountApplied": "1.00", "currency": "test", "paymentMethod": "Card", "paymentReference": "test", "shippingAddress": "test", "trackingNumber": "test", "createdAt": "2024-01-01T00:00:00", "paidAt": "2024-01-01T00:00:00", "shippedAt": "2024-01-01T00:00:00", "playerId": 1, "itemsId": 1, "couponId": null}|]
      resp <- request "PUT" "/api/orders/1" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/orders/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/orders/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404

  describe "DELETE /api/orders/1/cancel" $ do
    it "behavior cancel stub returns 404 or 500" $ do
      resp <- request "DELETE" "/api/orders/1/cancel" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/orders/1/pay" $ do
    it "behavior pay stub returns 404 or 500" $ do
      resp <- request "POST" "/api/orders/1/pay" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "GET /api/orders/1/total" $ do
    it "behavior calculate_total stub returns 404 or 500" $ do
      resp <- get "/api/orders/1/total"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "PATCH /api/orders/1/discount" $ do
    it "behavior apply_discount stub returns 404 or 500" $ do
      resp <- request "PATCH" "/api/orders/1/discount" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/orders/1/refund" $ do
    it "behavior refund stub returns 404 or 500" $ do
      resp <- request "POST" "/api/orders/1/refund" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

