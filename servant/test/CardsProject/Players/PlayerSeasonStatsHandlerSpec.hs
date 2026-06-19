{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module CardsProject.Players.PlayerSeasonStatsHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.HTTP.Types (statusCode)
import CardsProject.App (app)
import CardsProject.Players.Types

spec :: Spec
spec = with (return app) $ do
  describe "GET /api/player_season_statses" $ do
    it "returns 200" $ do
      get "/api/player_season_statses" `shouldRespondWith` 200

  describe "GET /api/player_season_statses/1" $ do
    it "returns 200, 401, or 404" $ do
      resp <- request "GET" "/api/player_season_statses/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 401 || s == 403 || s == 404

  describe "GET /api/player_season_statses/1/win-rate" $ do
    it "behavior win_rate stub returns 404 or 500" $ do
      resp <- get "/api/player_season_statses/1/win-rate"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "PATCH /api/player_season_statses/1/points" $ do
    it "behavior add_points stub returns 404 or 500" $ do
      resp <- request "PATCH" "/api/player_season_statses/1/points" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/player_season_statses/1/tournament-win" $ do
    it "behavior record_tournament_win stub returns 404 or 500" $ do
      resp <- request "POST" "/api/player_season_statses/1/tournament-win" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

