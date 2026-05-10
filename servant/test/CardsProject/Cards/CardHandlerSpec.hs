{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.CardHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.Wai (Application)
import Data.Aeson (encode, object, (.=))
import CardsProject.App (app)
import CardsProject.Cards.Types

spec :: SpecWith Application
spec = do
  describe "GET /api/cards" $ do
    it "returns 200" $ do
      get "/api/cards" `shouldRespondWith` 200

  describe "POST /api/cards" $ do
    it "creates and returns 201" $ do
      let body = encode (object ["name" .= ("test"), "cardType" .= ("Creature"), "rarity" .= ("Common"), "manaCost" .= (0), "manaColors" .= ("White"), "attack" .= (0), "defense" .= (0), "loyalty" .= (0), "description" .= ("test"), "flavorText" .= ("test"), "imageUrl" .= ("https://example.com"), "artistName" .= ("test"), "legalFormats" .= ("Standard"), "isBanned" .= (true), "isRestricted" .= (true), "powerLevel" .= (0), "setId" .= ("test"), "rulingsId" .= ("test"), "abilitiesId" .= ("test")])
      request "POST" "/api/cards" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/cards/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/cards/1"
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/cards/1" $ do
    it "returns 200 or 404" $ do
      let body = encode (object ["name" .= ("test"), "cardType" .= ("Creature"), "rarity" .= ("Common"), "manaCost" .= (0), "manaColors" .= ("White"), "attack" .= (0), "defense" .= (0), "loyalty" .= (0), "description" .= ("test"), "flavorText" .= ("test"), "imageUrl" .= ("https://example.com"), "artistName" .= ("test"), "legalFormats" .= ("Standard"), "isBanned" .= (true), "isRestricted" .= (true), "powerLevel" .= (0), "setId" .= ("test"), "rulingsId" .= ("test"), "abilitiesId" .= ("test")])
      resp <- request "PUT" "/api/cards/1" [("Content-Type","application/json")] body
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/cards/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/cards/1" [] ""
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 204 || s == 404

