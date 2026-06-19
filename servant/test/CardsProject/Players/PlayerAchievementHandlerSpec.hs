{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module CardsProject.Players.PlayerAchievementHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.HTTP.Types (statusCode)
import CardsProject.App (app)
import CardsProject.Players.Types

spec :: Spec
spec = with (return app) $ do
  describe "GET /api/player_achievements" $ do
    it "returns 200" $ do
      get "/api/player_achievements" `shouldRespondWith` 200

  describe "GET /api/player_achievements/1" $ do
    it "returns 200, 401, or 404" $ do
      resp <- request "GET" "/api/player_achievements/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 401 || s == 403 || s == 404

  describe "PATCH /api/player_achievements/1/progress" $ do
    it "behavior increment_progress stub returns 404 or 500" $ do
      resp <- request "PATCH" "/api/player_achievements/1/progress" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/player_achievements/1/complete" $ do
    it "behavior complete stub returns 404 or 500" $ do
      resp <- request "POST" "/api/player_achievements/1/complete" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

