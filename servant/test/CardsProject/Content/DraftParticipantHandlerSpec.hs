{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Content.DraftParticipantHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.Wai (Application)
import Data.Aeson (encode, object, (.=))
import CardsProject.App (app)
import CardsProject.Content.Types

spec :: SpecWith Application
spec = do
  describe "GET /api/draft_participants" $ do
    it "returns 200" $ do
      get "/api/draft_participants" `shouldRespondWith` 200

  describe "POST /api/draft_participants" $ do
    it "creates and returns 201" $ do
      let body = encode (object ["seatNumber" .= (0), "joinedAt" .= ("2024-01-01T00:00:00"), "sessionId" .= ("test"), "playerId" .= ("test"), "draftedCardsId" .= ("test")])
      request "POST" "/api/draft_participants" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/draft_participants/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/draft_participants/1"
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/draft_participants/1" $ do
    it "returns 200 or 404" $ do
      let body = encode (object ["seatNumber" .= (0), "joinedAt" .= ("2024-01-01T00:00:00"), "sessionId" .= ("test"), "playerId" .= ("test"), "draftedCardsId" .= ("test")])
      resp <- request "PUT" "/api/draft_participants/1" [("Content-Type","application/json")] body
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/draft_participants/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/draft_participants/1" [] ""
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 204 || s == 404

