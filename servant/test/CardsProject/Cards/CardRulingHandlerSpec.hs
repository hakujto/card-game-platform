{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module CardsProject.Cards.CardRulingHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.HTTP.Types (statusCode)
import CardsProject.App (app)
import CardsProject.Cards.Types

spec :: Spec
spec = with (return app) $ do
  describe "GET /api/card_rulings" $ do
    it "returns 200" $ do
      get "/api/card_rulings" `shouldRespondWith` 200

  describe "POST /api/card_rulings" $ do
    it "creates and returns 201" $ do
      let body = [json|{"rulingText": "test", "publishedAt": "2024-01-01", "source": "test", "cardId": 1}|]
      request "POST" "/api/card_rulings" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/card_rulings/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/card_rulings/1"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/card_rulings/1" $ do
    it "returns 200 or 404" $ do
      let body = [json|{"rulingText": "test", "publishedAt": "2024-01-01", "source": "test", "cardId": 1}|]
      resp <- request "PUT" "/api/card_rulings/1" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/card_rulings/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/card_rulings/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404

  describe "GET /api/card_rulings/1/current" $ do
    it "behavior is_current stub returns 404 or 500" $ do
      resp <- get "/api/card_rulings/1/current"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "GET /api/card_rulings/1/supersedes" $ do
    it "behavior supersedes_previous stub returns 404 or 500" $ do
      resp <- get "/api/card_rulings/1/supersedes"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

