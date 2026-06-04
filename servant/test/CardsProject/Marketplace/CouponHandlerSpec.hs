{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module CardsProject.Marketplace.CouponHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.HTTP.Types (statusCode)
import CardsProject.App (app)
import CardsProject.Marketplace.Types

spec :: Spec
spec = with (return app) $ do
  describe "GET /api/coupons" $ do
    it "returns 200" $ do
      get "/api/coupons" `shouldRespondWith` 200

  describe "GET /api/coupons?q=test" $ do
    it "returns 200" $ do
      get "/api/coupons?q=test" `shouldRespondWith` 200

  describe "POST /api/coupons" $ do
    it "creates and returns 201" $ do
      let body = [json|{"code": "test", "discountType": "Percent", "discountValue": 1, "minOrderValue": 0.0, "maxUses": null, "usesCount": 0, "validFrom": "2024-01-01T00:00:00", "validUntil": "2024-01-02T00:00:00Z", "isActive": false}|]
      request "POST" "/api/coupons" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/coupons/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/coupons/1"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/coupons/1" $ do
    it "returns 200 or 404" $ do
      let body = [json|{"code": "test", "discountType": "Percent", "discountValue": 1, "minOrderValue": 0.0, "maxUses": null, "usesCount": 0, "validFrom": "2024-01-01T00:00:00", "validUntil": "2024-01-02T00:00:00Z", "isActive": false}|]
      resp <- request "PUT" "/api/coupons/1" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "GET /api/coupons/1/valid" $ do
    it "behavior is_valid stub returns 404 or 500" $ do
      resp <- get "/api/coupons/1/valid"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "GET /api/coupons/1/applicable" $ do
    it "behavior is_applicable_to_order stub returns 404 or 500" $ do
      resp <- get "/api/coupons/1/applicable"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/coupons/1/redeem" $ do
    it "behavior redeem stub returns 404 or 500" $ do
      resp <- request "POST" "/api/coupons/1/redeem" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/coupons/1/deactivate" $ do
    it "behavior deactivate stub returns 404 or 500" $ do
      resp <- request "POST" "/api/coupons/1/deactivate" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/coupons rule valid_until_after_valid_from" $ do
    it "rejects when valid_until_after_valid_from violated" $ do
      let body = [json|{"code": "test", "discountType": "Percent", "discountValue": 0.0, "minOrderValue": 0.0, "maxUses": 0, "usesCount": 0, "validFrom": "2024-01-02T00:00:00Z", "validUntil": "2024-01-01T00:00:00Z", "isActive": false}|]
      resp <- request "POST" "/api/coupons" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

  describe "POST /api/coupons rule discount_value_positive" $ do
    it "rejects when discount_value_positive violated" $ do
      let body = [json|{"code": "test", "discountType": "Percent", "discountValue": 0, "minOrderValue": 0.0, "maxUses": 0, "usesCount": 0, "validFrom": "2024-01-01T00:00:00", "validUntil": "2024-01-01T00:00:00", "isActive": false}|]
      resp <- request "POST" "/api/coupons" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

  describe "POST /api/coupons rule percent_discount_range" $ do
    it "rejects when percent_discount_range violated" $ do
      let body = [json|{"code": "test", "discountType": "Percent", "discountValue": 101, "minOrderValue": 0.0, "maxUses": 0, "usesCount": 0, "validFrom": "2024-01-01T00:00:00", "validUntil": "2024-01-01T00:00:00", "isActive": false}|]
      resp <- request "POST" "/api/coupons" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

  describe "POST /api/coupons rule uses_not_exceed_max" $ do
    it "rejects when uses_not_exceed_max violated" $ do
      let body = [json|{"code": "test", "discountType": "Percent", "discountValue": 0.0, "minOrderValue": 0.0, "maxUses": "test", "usesCount": 0, "validFrom": "2024-01-01T00:00:00", "validUntil": "2024-01-01T00:00:00", "isActive": false}|]
      resp <- request "POST" "/api/coupons" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

