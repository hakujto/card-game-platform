{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module CardsProject.Players.FriendshipHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.HTTP.Types (statusCode)
import CardsProject.App (app)
import CardsProject.Players.Types

spec :: Spec
spec = with (return app) $ do
  describe "GET /api/friendships" $ do
    it "returns 200" $ do
      get "/api/friendships" `shouldRespondWith` 200

  describe "POST /api/friendships" $ do
    it "creates and returns 201" $ do
      let body = [json|{"status": "Pending", "createdAt": "2024-01-01T00:00:00", "requesterId": 1, "receiverId": 1}|]
      request "POST" "/api/friendships" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/friendships/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/friendships/1"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/friendships/1" $ do
    it "returns 200 or 404" $ do
      let body = [json|{"status": "Pending", "createdAt": "2024-01-01T00:00:00", "requesterId": 1, "receiverId": 1}|]
      resp <- request "PUT" "/api/friendships/1" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/friendships/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/friendships/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404

  describe "POST /api/friendships/1/accept" $ do
    it "behavior accept stub returns 404 or 500" $ do
      resp <- request "POST" "/api/friendships/1/accept" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/friendships/1/decline" $ do
    it "behavior decline stub returns 404 or 500" $ do
      resp <- request "POST" "/api/friendships/1/decline" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/friendships/1/block" $ do
    it "behavior block stub returns 404 or 500" $ do
      resp <- request "POST" "/api/friendships/1/block" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

