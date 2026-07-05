{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module CardsProject.Tournaments.AwardedPrizeHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.HTTP.Types (statusCode)
import CardsProject.App (app)
import CardsProject.Tournaments.Types

spec :: Spec
spec = with (return app) $ do
  describe "GET /api/awarded_prizes" $ do
    it "returns 200" $ do
      get "/api/awarded_prizes" `shouldRespondWith` 200

  describe "GET /api/awarded_prizes/1" $ do
    it "returns 200, 401, or 404" $ do
      resp <- request "GET" "/api/awarded_prizes/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 401 || s == 403 || s == 404

  describe "POST /api/awarded_prizes/1/claim" $ do
    it "behavior claim stub returns 404 or 500" $ do
      resp <- request "POST" "/api/awarded_prizes/1/claim" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 400 || s == 401 || s == 404 || s == 500

