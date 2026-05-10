{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Players.CraftingIngredientHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.Wai (Application)
import Data.Aeson (encode, object, (.=))
import CardsProject.App (app)
import CardsProject.Players.Types

spec :: SpecWith Application
spec = do
  describe "GET /api/crafting_ingredients" $ do
    it "returns 200" $ do
      get "/api/crafting_ingredients" `shouldRespondWith` 200

  describe "POST /api/crafting_ingredients" $ do
    it "creates and returns 201" $ do
      let body = encode (object ["quantity" .= (0), "recipeId" .= ("test"), "cardId" .= ("test")])
      request "POST" "/api/crafting_ingredients" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/crafting_ingredients/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/crafting_ingredients/1"
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/crafting_ingredients/1" $ do
    it "returns 200 or 404" $ do
      let body = encode (object ["quantity" .= (0), "recipeId" .= ("test"), "cardId" .= ("test")])
      resp <- request "PUT" "/api/crafting_ingredients/1" [("Content-Type","application/json")] body
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/crafting_ingredients/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/crafting_ingredients/1" [] ""
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 204 || s == 404

