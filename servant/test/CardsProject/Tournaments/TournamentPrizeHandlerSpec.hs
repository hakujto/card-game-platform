{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.TournamentPrizeHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.Wai (Application)
import Data.Aeson (encode, object, (.=))
import CardsProject.App (app)
import CardsProject.Tournaments.Types

spec :: SpecWith Application
spec = do
  describe "GET /api/tournament_prizes" $ do
    it "returns 200" $ do
      get "/api/tournament_prizes" `shouldRespondWith` 200

  describe "POST /api/tournament_prizes" $ do
    it "creates and returns 201" $ do
      let body = encode (object ["placementFrom" .= (0), "placementTo" .= (0), "prizeType" .= ("Currency"), "amount" .= ("1.00"), "description" .= ("test"), "packsCount" .= (0), "seasonPoints" .= (0), "tournamentId" .= ("test")])
      request "POST" "/api/tournament_prizes" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/tournament_prizes/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/tournament_prizes/1"
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/tournament_prizes/1" $ do
    it "returns 200 or 404" $ do
      let body = encode (object ["placementFrom" .= (0), "placementTo" .= (0), "prizeType" .= ("Currency"), "amount" .= ("1.00"), "description" .= ("test"), "packsCount" .= (0), "seasonPoints" .= (0), "tournamentId" .= ("test")])
      resp <- request "PUT" "/api/tournament_prizes/1" [("Content-Type","application/json")] body
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/tournament_prizes/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/tournament_prizes/1" [] ""
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 204 || s == 404

