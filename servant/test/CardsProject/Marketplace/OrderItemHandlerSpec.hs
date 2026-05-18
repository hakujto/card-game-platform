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
      let body = [json|{"quantity": 0, "priceAtPurchase": "1.00", "foil": true, "orderId": null, "productId": 1}|]
      request "POST" "/api/order_items" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/order_items/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/order_items/1"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/order_items/1" $ do
    it "returns 200 or 404" $ do
      let body = [json|{"quantity": 0, "priceAtPurchase": "1.00", "foil": true, "orderId": null, "productId": 1}|]
      resp <- request "PUT" "/api/order_items/1" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/order_items/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/order_items/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404

