{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.GameHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.Wai (Application)
import Data.Aeson (encode, object, (.=))
import CardsProject.App (app)
import CardsProject.Tournaments.Types

spec :: SpecWith Application
spec = do
  describe "GET /api/games" $ do
    it "returns 200" $ do
      get "/api/games" `shouldRespondWith` 200

  describe "POST /api/games" $ do
    it "creates and returns 201" $ do
      let body = encode (object ["gameNumber" .= (0), "winnerSide" .= ("Player1"), "turnsPlayed" .= (0), "durationSeconds" .= (0), "endedBy" .= ("Normal"), "replayUrl" .= ("https://example.com"), "matchId" .= ("test"), "winnerId" .= ("test")])
      request "POST" "/api/games" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/games/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/games/1"
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/games/1" $ do
    it "returns 200 or 404" $ do
      let body = encode (object ["gameNumber" .= (0), "winnerSide" .= ("Player1"), "turnsPlayed" .= (0), "durationSeconds" .= (0), "endedBy" .= ("Normal"), "replayUrl" .= ("https://example.com"), "matchId" .= ("test"), "winnerId" .= ("test")])
      resp <- request "PUT" "/api/games/1" [("Content-Type","application/json")] body
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/games/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/games/1" [] ""
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 204 || s == 404

