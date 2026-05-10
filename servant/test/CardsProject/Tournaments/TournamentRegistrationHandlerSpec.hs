{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.TournamentRegistrationHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.Wai (Application)
import Data.Aeson (encode, object, (.=))
import CardsProject.App (app)
import CardsProject.Tournaments.Types

spec :: SpecWith Application
spec = do
  describe "GET /api/tournament_registrations" $ do
    it "returns 200" $ do
      get "/api/tournament_registrations" `shouldRespondWith` 200

  describe "POST /api/tournament_registrations" $ do
    it "creates and returns 201" $ do
      let body = encode (object ["status" .= ("Registered"), "seed" .= (0), "finalStanding" .= (0), "pointsEarned" .= (0), "registeredAt" .= ("2024-01-01T00:00:00"), "tournamentId" .= ("test"), "playerId" .= ("test"), "deckId" .= ("test")])
      request "POST" "/api/tournament_registrations" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/tournament_registrations/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/tournament_registrations/1"
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/tournament_registrations/1" $ do
    it "returns 200 or 404" $ do
      let body = encode (object ["status" .= ("Registered"), "seed" .= (0), "finalStanding" .= (0), "pointsEarned" .= (0), "registeredAt" .= ("2024-01-01T00:00:00"), "tournamentId" .= ("test"), "playerId" .= ("test"), "deckId" .= ("test")])
      resp <- request "PUT" "/api/tournament_registrations/1" [("Content-Type","application/json")] body
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/tournament_registrations/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/tournament_registrations/1" [] ""
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 204 || s == 404

