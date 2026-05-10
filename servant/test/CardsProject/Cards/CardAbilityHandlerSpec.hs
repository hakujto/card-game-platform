{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.CardAbilityHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.Wai (Application)
import Data.Aeson (encode, object, (.=))
import CardsProject.App (app)
import CardsProject.Cards.Types

spec :: SpecWith Application
spec = do
  describe "GET /api/card_abilities" $ do
    it "returns 200" $ do
      get "/api/card_abilities" `shouldRespondWith` 200

  describe "POST /api/card_abilities" $ do
    it "creates and returns 201" $ do
      let body = encode (object ["abilityType" .= ("Keyword"), "keyword" .= ("test"), "abilityText" .= ("test"), "timing" .= ("Any"), "cardId" .= ("test")])
      request "POST" "/api/card_abilities" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/card_abilities/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/card_abilities/1"
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/card_abilities/1" $ do
    it "returns 200 or 404" $ do
      let body = encode (object ["abilityType" .= ("Keyword"), "keyword" .= ("test"), "abilityText" .= ("test"), "timing" .= ("Any"), "cardId" .= ("test")])
      resp <- request "PUT" "/api/card_abilities/1" [("Content-Type","application/json")] body
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/card_abilities/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/card_abilities/1" [] ""
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 204 || s == 404

