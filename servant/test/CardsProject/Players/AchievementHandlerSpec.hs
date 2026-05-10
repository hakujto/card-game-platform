{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Players.AchievementHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.Wai (Application)
import Data.Aeson (encode, object, (.=))
import CardsProject.App (app)
import CardsProject.Players.Types

spec :: SpecWith Application
spec = do
  describe "GET /api/achievements" $ do
    it "returns 200" $ do
      get "/api/achievements" `shouldRespondWith` 200

  describe "POST /api/achievements" $ do
    it "creates and returns 201" $ do
      let body = encode (object ["name" .= ("test"), "description" .= ("test"), "iconUrl" .= ("https://example.com"), "points" .= (0), "rarity" .= ("Common"), "isHidden" .= (true)])
      request "POST" "/api/achievements" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/achievements/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/achievements/1"
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/achievements/1" $ do
    it "returns 200 or 404" $ do
      let body = encode (object ["name" .= ("test"), "description" .= ("test"), "iconUrl" .= ("https://example.com"), "points" .= (0), "rarity" .= ("Common"), "isHidden" .= (true)])
      resp <- request "PUT" "/api/achievements/1" [("Content-Type","application/json")] body
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/achievements/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/achievements/1" [] ""
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 204 || s == 404

