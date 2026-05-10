{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Tournaments.SeasonHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.Wai (Application)
import Data.Aeson (encode, object, (.=))
import CardsProject.App (app)
import CardsProject.Tournaments.Types

spec :: SpecWith Application
spec = do
  describe "GET /api/seasons" $ do
    it "returns 200" $ do
      get "/api/seasons" `shouldRespondWith` 200

  describe "POST /api/seasons" $ do
    it "creates and returns 201" $ do
      let body = encode (object ["name" .= ("test"), "startDate" .= ("2024-01-01"), "endDate" .= ("2024-01-01"), "format" .= ("Standard"), "isActive" .= (true), "rewardDescription" .= ("test")])
      request "POST" "/api/seasons" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/seasons/1" $ do
    it "returns 200 or 404" $ do
      resp <- get "/api/seasons/1"
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "PUT /api/seasons/1" $ do
    it "returns 200 or 404" $ do
      let body = encode (object ["name" .= ("test"), "startDate" .= ("2024-01-01"), "endDate" .= ("2024-01-01"), "format" .= ("Standard"), "isActive" .= (true), "rewardDescription" .= ("test")])
      resp <- request "PUT" "/api/seasons/1" [("Content-Type","application/json")] body
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 200 || s == 404

  describe "DELETE /api/seasons/1" $ do
    it "returns 204 or 404" $ do
      resp <- request "DELETE" "/api/seasons/1" [] ""
      liftIO $ simpleStatus resp `shouldSatisfy` \s -> s == 204 || s == 404

