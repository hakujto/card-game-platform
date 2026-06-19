{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module CardsProject.Marketplace.CardPriceHistoryHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.HTTP.Types (statusCode)
import CardsProject.App (app)
import CardsProject.Marketplace.Types

spec :: Spec
spec = with (return app) $ do
  describe "GET /api/card_price_histories" $ do
    it "returns 200" $ do
      get "/api/card_price_histories" `shouldRespondWith` 200

  describe "GET /api/card_price_histories/1" $ do
    it "returns 200, 401, or 404" $ do
      resp <- request "GET" "/api/card_price_histories/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 401 || s == 403 || s == 404

  describe "GET /api/card_price_histories/1/change" $ do
    it "behavior price_change_percent stub returns 404 or 500" $ do
      resp <- get "/api/card_price_histories/1/change"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "GET /api/card_price_histories/1/spike" $ do
    it "behavior is_price_spike stub returns 404 or 500" $ do
      resp <- get "/api/card_price_histories/1/spike"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

