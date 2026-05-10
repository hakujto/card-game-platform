{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Content.StreamHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.Wai (Application)
import Data.Aeson (encode, object, (.=))
import CardsProject.App (app)
import CardsProject.Content.Types

spec :: SpecWith Application
spec = do
  describe "GET /api/streams" $ do
    it "returns 200" $ do
      get "/api/streams" `shouldRespondWith` 200

  describe "POST /api/streams" $ do
    it "creates and returns 201" $ do
      let body = encode (object ["title" .= ("test"), "streamUrl" .= ("https://example.com"), "platform" .= ("Twitch"), "status" .= ("Scheduled"), "viewerCountPeak" .= (0), "scheduledStart" .= ("2024-01-01T00:00:00"), "actualStart" .= ("2024-01-01T00:00:00"), "endedAt" .= ("2024-01-01T00:00:00"), "vodUrl" .= ("https://example.com"), "tournamentId" .= ("test"), "streamerId" .= ("test")])
      request "POST" "/api/streams" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/streams/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/streams/1"
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/streams/1" $ do
    it "returns 200 or 404" $ do
      let body = encode (object ["title" .= ("test"), "streamUrl" .= ("https://example.com"), "platform" .= ("Twitch"), "status" .= ("Scheduled"), "viewerCountPeak" .= (0), "scheduledStart" .= ("2024-01-01T00:00:00"), "actualStart" .= ("2024-01-01T00:00:00"), "endedAt" .= ("2024-01-01T00:00:00"), "vodUrl" .= ("https://example.com"), "tournamentId" .= ("test"), "streamerId" .= ("test")])
      resp <- request "PUT" "/api/streams/1" [("Content-Type","application/json")] body
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/streams/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/streams/1" [] ""
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 204 || s == 404

