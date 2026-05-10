{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.ProductHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.Wai (Application)
import Data.Aeson (encode, object, (.=))
import CardsProject.App (app)
import CardsProject.Marketplace.Types

spec :: SpecWith Application
spec = do
  describe "GET /api/products" $ do
    it "returns 200" $ do
      get "/api/products" `shouldRespondWith` 200

  describe "POST /api/products" $ do
    it "creates and returns 201" $ do
      let body = encode (object ["name" .= ("test"), "productType" .= ("SingleCard"), "price" .= ("1.00"), "stock" .= (0), "active" .= (true), "discountPercent" .= (0), "description" .= ("test"), "imageUrl" .= ("https://example.com"), "featured" .= (true), "cardId" .= ("test"), "cardSetId" .= ("test")])
      request "POST" "/api/products" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/products/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/products/1"
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/products/1" $ do
    it "returns 200 or 404" $ do
      let body = encode (object ["name" .= ("test"), "productType" .= ("SingleCard"), "price" .= ("1.00"), "stock" .= (0), "active" .= (true), "discountPercent" .= (0), "description" .= ("test"), "imageUrl" .= ("https://example.com"), "featured" .= (true), "cardId" .= ("test"), "cardSetId" .= ("test")])
      resp <- request "PUT" "/api/products/1" [("Content-Type","application/json")] body
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/products/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/products/1" [] ""
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 204 || s == 404

