{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.TournamentHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.Wai (Application)
import Data.Aeson (encode, object, (.=))
import CardsProject.App (app)
import CardsProject.Tournaments.Types

spec :: SpecWith Application
spec = do
  describe "GET /api/tournaments" $ do
    it "returns 200" $ do
      get "/api/tournaments" `shouldRespondWith` 200

  describe "POST /api/tournaments" $ do
    it "creates and returns 201" $ do
      let body = encode (object ["name" .= ("test"), "description" .= ("test"), "format" .= ("Standard"), "tournamentType" .= ("Swiss"), "status" .= ("Draft"), "maxPlayers" .= (0), "entryFee" .= ("1.00"), "prizePool" .= ("1.00"), "startTime" .= ("2024-01-01T00:00:00"), "endTime" .= ("2024-01-01T00:00:00"), "isOnline" .= (true), "location" .= ("test"), "rulesText" .= ("test"), "createdAt" .= ("2024-01-01T00:00:00"), "seasonId" .= ("test"), "organizerId" .= ("test"), "registrationsId" .= ("test"), "roundsId" .= ("test"), "prizesId" .= ("test")])
      request "POST" "/api/tournaments" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/tournaments/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/tournaments/1"
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/tournaments/1" $ do
    it "returns 200 or 404" $ do
      let body = encode (object ["name" .= ("test"), "description" .= ("test"), "format" .= ("Standard"), "tournamentType" .= ("Swiss"), "status" .= ("Draft"), "maxPlayers" .= (0), "entryFee" .= ("1.00"), "prizePool" .= ("1.00"), "startTime" .= ("2024-01-01T00:00:00"), "endTime" .= ("2024-01-01T00:00:00"), "isOnline" .= (true), "location" .= ("test"), "rulesText" .= ("test"), "createdAt" .= ("2024-01-01T00:00:00"), "seasonId" .= ("test"), "organizerId" .= ("test"), "registrationsId" .= ("test"), "roundsId" .= ("test"), "prizesId" .= ("test")])
      resp <- request "PUT" "/api/tournaments/1" [("Content-Type","application/json")] body
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/tournaments/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/tournaments/1" [] ""
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 204 || s == 404

