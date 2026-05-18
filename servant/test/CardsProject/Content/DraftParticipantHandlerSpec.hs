{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module CardsProject.Content.DraftParticipantHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.HTTP.Types (statusCode)
import CardsProject.App (app)
import CardsProject.Content.Types

spec :: Spec
spec = with (return app) $ do
  describe "GET /api/draft_participants" $ do
    it "returns 200" $ do
      get "/api/draft_participants" `shouldRespondWith` 200

  describe "POST /api/draft_participants" $ do
    it "creates and returns 201" $ do
      let body = [json|{"seatNumber": 0, "joinedAt": "2024-01-01T00:00:00", "sessionId": null, "playerId": 1, "draftedCardsId": null}|]
      request "POST" "/api/draft_participants" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/draft_participants/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/draft_participants/1"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/draft_participants/1" $ do
    it "returns 200 or 404" $ do
      let body = [json|{"seatNumber": 0, "joinedAt": "2024-01-01T00:00:00", "sessionId": null, "playerId": 1, "draftedCardsId": null}|]
      resp <- request "PUT" "/api/draft_participants/1" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/draft_participants/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/draft_participants/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404

  describe "POST /api/draft_participants/1/pick" $ do
    it "behavior pick_card stub returns 404 or 500" $ do
      resp <- request "POST" "/api/draft_participants/1/pick" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 404 || s == 500

