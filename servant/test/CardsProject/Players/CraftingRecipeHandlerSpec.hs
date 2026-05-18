{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module CardsProject.Players.CraftingRecipeHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.HTTP.Types (statusCode)
import CardsProject.App (app)
import CardsProject.Players.Types

spec :: Spec
spec = with (return app) $ do
  describe "GET /api/crafting_recipes" $ do
    it "returns 200" $ do
      get "/api/crafting_recipes" `shouldRespondWith` 200

  describe "POST /api/crafting_recipes" $ do
    it "creates and returns 201" $ do
      let body = [json|{"dustCost": 0, "isAvailable": true, "resultCardId": 1}|]
      request "POST" "/api/crafting_recipes" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/crafting_recipes/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/crafting_recipes/1"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/crafting_recipes/1" $ do
    it "returns 200 or 404" $ do
      let body = [json|{"dustCost": 0, "isAvailable": true, "resultCardId": 1}|]
      resp <- request "PUT" "/api/crafting_recipes/1" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/crafting_recipes/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/crafting_recipes/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404

