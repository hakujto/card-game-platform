{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Players.PlayerSeasonStatsHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.Wai (Application)
import Data.Aeson (encode, object, (.=))
import CardsProject.App (app)
import CardsProject.Players.Types

spec :: SpecWith Application
spec = do
  describe "GET /api/player_season_statses" $ do
    it "returns 200" $ do
      get "/api/player_season_statses" `shouldRespondWith` 200

  describe "POST /api/player_season_statses" $ do
    it "creates and returns 201" $ do
      let body = encode (object ["wins" .= (0), "losses" .= (0), "draws" .= (0), "tournamentWins" .= (0), "highestRank" .= ("Bronze"), "seasonPoints" .= (0), "playerId" .= ("test"), "seasonId" .= ("test")])
      request "POST" "/api/player_season_statses" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/player_season_statses/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/player_season_statses/1"
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/player_season_statses/1" $ do
    it "returns 200 or 404" $ do
      let body = encode (object ["wins" .= (0), "losses" .= (0), "draws" .= (0), "tournamentWins" .= (0), "highestRank" .= ("Bronze"), "seasonPoints" .= (0), "playerId" .= ("test"), "seasonId" .= ("test")])
      resp <- request "PUT" "/api/player_season_statses/1" [("Content-Type","application/json")] body
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/player_season_statses/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/player_season_statses/1" [] ""
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 204 || s == 404

