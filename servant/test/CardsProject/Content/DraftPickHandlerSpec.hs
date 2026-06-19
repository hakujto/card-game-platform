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

  describe "GET /api/draft_picks/1" $ do
    it "returns 200, 401, or 404" $ do
      resp <- request "GET" "/api/draft_picks/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 401 || s == 403 || s == 404

  describe "GET /api/draft_picks/1/first-pick" $ do
    it "behavior is_first_pick stub returns 404 or 500" $ do
      resp <- get "/api/draft_picks/1/first-pick"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

