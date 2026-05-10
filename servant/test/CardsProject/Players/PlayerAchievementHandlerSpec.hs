{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Players.PlayerAchievementHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.Wai (Application)
import Data.Aeson (encode, object, (.=))
import CardsProject.App (app)
import CardsProject.Players.Types

spec :: SpecWith Application
spec = do
  describe "GET /api/player_achievements" $ do
    it "returns 200" $ do
      get "/api/player_achievements" `shouldRespondWith` 200

  describe "POST /api/player_achievements" $ do
    it "creates and returns 201" $ do
      let body = encode (object ["earnedAt" .= ("2024-01-01T00:00:00"), "progress" .= (0), "isCompleted" .= (true), "playerId" .= ("test"), "achievementId" .= ("test")])
      request "POST" "/api/player_achievements" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/player_achievements/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/player_achievements/1"
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/player_achievements/1" $ do
    it "returns 200 or 404" $ do
      let body = encode (object ["earnedAt" .= ("2024-01-01T00:00:00"), "progress" .= (0), "isCompleted" .= (true), "playerId" .= ("test"), "achievementId" .= ("test")])
      resp <- request "PUT" "/api/player_achievements/1" [("Content-Type","application/json")] body
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/player_achievements/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/player_achievements/1" [] ""
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 204 || s == 404

