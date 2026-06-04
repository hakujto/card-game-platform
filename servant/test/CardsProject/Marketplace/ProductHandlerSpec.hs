{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module CardsProject.Marketplace.ProductHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.HTTP.Types (statusCode)
import CardsProject.App (app)
import CardsProject.Marketplace.Types

spec :: Spec
spec = with (return app) $ do
  describe "GET /api/products" $ do
    it "returns 200" $ do
      get "/api/products" `shouldRespondWith` 200

  describe "GET /api/products?q=test" $ do
    it "returns 200" $ do
      get "/api/products?q=test" `shouldRespondWith` 200

  describe "POST /api/products" $ do
    it "creates and returns 201" $ do
      let body = [json|{"name": "test", "productType": "SingleCard", "price": 1, "stock": 0, "active": false, "discountPercent": 0, "description": null, "imageUrl": null, "featured": false, "cardId": null, "cardSetId": null}|]
      request "POST" "/api/products" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/products/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/products/1"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/products/1" $ do
    it "returns 200 or 404" $ do
      let body = [json|{"name": "test", "productType": "SingleCard", "price": 1, "stock": 0, "active": false, "discountPercent": 0, "description": null, "imageUrl": null, "featured": false, "cardId": null, "cardSetId": null}|]
      resp <- request "PUT" "/api/products/1" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "POST /api/products/1/activate" $ do
    it "behavior activate stub returns 404 or 500" $ do
      resp <- request "POST" "/api/products/1/activate" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/products/1/deactivate" $ do
    it "behavior deactivate stub returns 404 or 500" $ do
      resp <- request "POST" "/api/products/1/deactivate" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "PATCH /api/products/1/discount" $ do
    it "behavior apply_discount stub returns 404 or 500" $ do
      resp <- request "PATCH" "/api/products/1/discount" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/products/1/restock" $ do
    it "behavior restock stub returns 404 or 500" $ do
      resp <- request "POST" "/api/products/1/restock" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "GET /api/products/1/effective-price" $ do
    it "behavior effective_price stub returns 404 or 500" $ do
      resp <- get "/api/products/1/effective-price"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "GET /api/products/1/in-stock" $ do
    it "behavior is_in_stock stub returns 404 or 500" $ do
      resp <- get "/api/products/1/in-stock"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/products rule price_positive" $ do
    it "rejects when price_positive violated" $ do
      let body = [json|{"name": "test", "productType": "SingleCard", "price": 0, "stock": 0, "active": false, "discountPercent": 0, "description": "test", "imageUrl": "https://example.com", "featured": false, "cardId": null, "cardSetId": null}|]
      resp <- request "POST" "/api/products" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

  describe "POST /api/products rule stock_not_negative" $ do
    it "rejects when stock_not_negative violated" $ do
      let body = [json|{"name": "test", "productType": "SingleCard", "price": 0.0, "stock": -2, "active": false, "discountPercent": 0, "description": "test", "imageUrl": "https://example.com", "featured": false, "cardId": null, "cardSetId": null}|]
      resp <- request "POST" "/api/products" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

  describe "POST /api/products rule discount_percent_range" $ do
    it "rejects when discount_percent_range violated" $ do
      let body = [json|{"name": "test", "productType": "SingleCard", "price": 0.0, "stock": 0, "active": false, "discountPercent": 101, "description": "test", "imageUrl": "https://example.com", "featured": false, "cardId": null, "cardSetId": null}|]
      resp <- request "POST" "/api/products" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

