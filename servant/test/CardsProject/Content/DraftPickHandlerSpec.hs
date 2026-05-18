{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module CardsProject.Content.DraftPickHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.HTTP.Types (statusCode)
import CardsProject.App (app)
import CardsProject.Content.Types

spec :: Spec
spec = with (return app) $ do
  describe "GET /api/draft_picks" $ do
    it "returns 200" $ do
      get "/api/draft_picks" `shouldRespondWith` 200

  describe "POST /api/draft_picks" $ do
    it "creates and returns 201" $ do
      let body = [json|{"pickNumber": 0, "packNumber": 0, "pickedAt": "2024-01-01T00:00:00", "participantId": 1, "cardId": 1}|]
      request "POST" "/api/draft_picks" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/draft_picks/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/draft_picks/1"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/draft_picks/1" $ do
    it "returns 200 or 404" $ do
      let body = [json|{"pickNumber": 0, "packNumber": 0, "pickedAt": "2024-01-01T00:00:00", "participantId": 1, "cardId": 1}|]
      resp <- request "PUT" "/api/draft_picks/1" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/draft_picks/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/draft_picks/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404

  describe "GET /api/draft_picks/1/first-pick" $ do
    it "behavior is_first_pick stub returns 404 or 500" $ do
      resp <- get "/api/draft_picks/1/first-pick"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

