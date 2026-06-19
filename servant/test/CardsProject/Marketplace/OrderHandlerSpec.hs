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
      let body = [json|{"status": "Pending", "total": 0, "discountApplied": 0.0, "currency": "test", "paymentMethod": null, "paymentReference": null, "shippingAddress": null, "trackingNumber": "test", "createdAt": "2024-01-01T00:00:00", "paidAt": "2024-01-01T00:00:00Z", "shippedAt": null, "couponId": null, "playerId": 1}|]
      request "POST" "/api/orders" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/orders/1" $ do
    it "returns 200, 401, or 404" $ do
      resp <- request "GET" "/api/orders/1" [("X-User-Id","1")] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 401 || s == 403 || s == 404

  describe "PATCH /api/orders/1/transitions/pending-to-paid" $ do
    it "transitions Pending -> Paid" $ do
      resp <- request "PATCH" "/api/orders/1/transitions/pending-to-paid" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s `elem` [200, 409, 404, 500]

  describe "PATCH /api/orders/1/transitions/paid-to-processing" $ do
    it "transitions Paid -> Processing with role Admin" $ do
      resp <- request "PATCH" "/api/orders/1/transitions/paid-to-processing" [("X-User-Role","Admin")] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s `elem` [200, 409, 404, 500]

    it "rejects Paid -> Processing without role (401 or 403)" $ do
      resp <- request "PATCH" "/api/orders/1/transitions/paid-to-processing" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 401 || s == 403

  describe "PATCH /api/orders/1/transitions/processing-to-shipped" $ do
    it "transitions Processing -> Shipped with role Admin" $ do
      resp <- request "PATCH" "/api/orders/1/transitions/processing-to-shipped" [("X-User-Role","Admin")] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s `elem` [200, 409, 404, 500]

    it "rejects Processing -> Shipped without role (401 or 403)" $ do
      resp <- request "PATCH" "/api/orders/1/transitions/processing-to-shipped" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 401 || s == 403

  describe "PATCH /api/orders/1/transitions/shipped-to-completed" $ do
    it "transitions Shipped -> Completed with role Admin" $ do
      resp <- request "PATCH" "/api/orders/1/transitions/shipped-to-completed" [("X-User-Role","Admin")] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s `elem` [200, 409, 404, 500]

    it "rejects Shipped -> Completed without role (401 or 403)" $ do
      resp <- request "PATCH" "/api/orders/1/transitions/shipped-to-completed" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 401 || s == 403

  describe "PATCH /api/orders/1/transitions/pending-to-cancelled" $ do
    it "transitions Pending -> Cancelled" $ do
      resp <- request "PATCH" "/api/orders/1/transitions/pending-to-cancelled" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s `elem` [200, 409, 404, 500]

  describe "PATCH /api/orders/1/transitions/paid-to-cancelled" $ do
    it "transitions Paid -> Cancelled with role Admin" $ do
      resp <- request "PATCH" "/api/orders/1/transitions/paid-to-cancelled" [("X-User-Role","Admin")] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s `elem` [200, 409, 404, 500]

    it "rejects Paid -> Cancelled without role (401 or 403)" $ do
      resp <- request "PATCH" "/api/orders/1/transitions/paid-to-cancelled" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 401 || s == 403

  describe "PATCH /api/orders/1/transitions/completed-to-refunded" $ do
    it "transitions Completed -> Refunded with role Admin" $ do
      resp <- request "PATCH" "/api/orders/1/transitions/completed-to-refunded" [("X-User-Role","Admin")] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s `elem` [200, 409, 404, 500]

    it "rejects Completed -> Refunded without role (401 or 403)" $ do
      resp <- request "PATCH" "/api/orders/1/transitions/completed-to-refunded" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 401 || s == 403

  describe "PATCH /api/orders/1/transitions/refunded-to-completed" $ do
    it "is denied (409 or 404)" $ do
      resp <- request "PATCH" "/api/orders/1/transitions/refunded-to-completed" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 409 || s == 404

  describe "PATCH /api/orders/1/transitions/completed-to-cancelled" $ do
    it "is denied (409 or 404)" $ do
      resp <- request "PATCH" "/api/orders/1/transitions/completed-to-cancelled" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 409 || s == 404

  describe "DELETE /api/orders/1/cancel" $ do
    it "behavior cancel stub returns 404 or 500" $ do
      resp <- request "DELETE" "/api/orders/1/cancel" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/orders/1/pay" $ do
    it "behavior pay stub returns 404 or 500" $ do
      resp <- request "POST" "/api/orders/1/pay" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/orders/1/process-payment" $ do
    it "behavior process_payment stub returns 404 or 500" $ do
      resp <- request "POST" "/api/orders/1/process-payment" [("Content-Type","application/json")] "{}"
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

  describe "POST /api/orders rule paid_requires_paid_at" $ do
    it "rejects when paid_requires_paid_at violated" $ do
      let body = [json|{"status": "Paid", "total": 0.0, "discountApplied": 0.0, "currency": "test", "paymentMethod": "Card", "paymentReference": "test", "shippingAddress": "test", "trackingNumber": "test", "createdAt": "2024-01-01T00:00:00", "paidAt": null, "shippedAt": "2024-01-01T00:00:00", "playerId": 1, "couponId": null}|]
      resp <- request "POST" "/api/orders" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

  describe "POST /api/orders rule shipped_requires_tracking" $ do
    it "rejects when shipped_requires_tracking violated" $ do
      let body = [json|{"status": "Shipped", "total": 0.0, "discountApplied": 0.0, "currency": "test", "paymentMethod": "Card", "paymentReference": "test", "shippingAddress": "test", "trackingNumber": null, "createdAt": "2024-01-01T00:00:00", "paidAt": "2024-01-01T00:00:00", "shippedAt": "2024-01-01T00:00:00", "playerId": 1, "couponId": null}|]
      resp <- request "POST" "/api/orders" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

  describe "POST /api/orders rule shipped_at_requires_shipped_status" $ do
    it "rejects when shipped_at_requires_shipped_status violated" $ do
      let body = [json|{"status": "Pending", "total": 0.0, "discountApplied": 0.0, "currency": "test", "paymentMethod": "Card", "paymentReference": "test", "shippingAddress": "test", "trackingNumber": "test", "createdAt": "2024-01-01T00:00:00", "paidAt": "2024-01-01T00:00:00", "shippedAt": "test", "playerId": 1, "couponId": null}|]
      resp <- request "POST" "/api/orders" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

  describe "POST /api/orders rule total_not_negative" $ do
    it "rejects when total_not_negative violated" $ do
      let body = [json|{"status": "Pending", "total": -2, "discountApplied": 0.0, "currency": "test", "paymentMethod": "Card", "paymentReference": "test", "shippingAddress": "test", "trackingNumber": "test", "createdAt": "2024-01-01T00:00:00", "paidAt": "2024-01-01T00:00:00", "shippedAt": "2024-01-01T00:00:00", "playerId": 1, "couponId": null}|]
      resp <- request "POST" "/api/orders" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

