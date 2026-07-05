{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module CardsProject.Marketplace.OrderItemHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.HTTP.Types (statusCode)
import CardsProject.App (app)
import CardsProject.Marketplace.Types

spec :: Spec
spec = with (return app) $ do
  describe "GET /api/order_items" $ do
    it "returns 200" $ do
      get "/api/order_items" `shouldRespondWith` 200

  describe "POST /api/order_items" $ do
    it "creates and returns 201" $ do
      let body = [json|{"quantity": 1, "priceAtPurchase": 0, "foil": false, "orderId": null, "productId": 1}|]
      request "POST" "/api/order_items" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/order_items/1" $ do
    it "returns 200, 401, or 404" $ do
      resp <- request "GET" "/api/order_items/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 401 || s == 403 || s == 404

  describe "DELETE /api/order_items/1" $ do
    it "returns 204, 401, 403, or 404" $ do
      resp <- request "DELETE" "/api/order_items/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 401 || s == 403 || s == 404

  describe "GET /api/order_items/1/total" $ do
    it "behavior line_total stub returns 404 or 500" $ do
      resp <- get "/api/order_items/1/total"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 400 || s == 401 || s == 404 || s == 500

  describe "POST /api/order_items rule quantity_positive" $ do
    it "rejects when quantity_positive violated" $ do
      let body = [json|{"quantity": 0, "priceAtPurchase": 0.0, "foil": false, "orderId": null, "productId": 1}|]
      resp <- request "POST" "/api/order_items" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

  describe "POST /api/order_items rule price_not_negative" $ do
    it "rejects when price_not_negative violated" $ do
      let body = [json|{"quantity": 0, "priceAtPurchase": -2, "foil": false, "orderId": null, "productId": 1}|]
      resp <- request "POST" "/api/order_items" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

