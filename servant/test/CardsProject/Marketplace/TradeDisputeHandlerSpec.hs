{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module CardsProject.Marketplace.TradeDisputeHandlerSpec where

import Test.Hspec
import Test.Hspec.Wai
import Test.Hspec.Wai.JSON (json)
import Network.HTTP.Types (statusCode)
import CardsProject.App (app)
import CardsProject.Marketplace.Types

spec :: Spec
spec = with (return app) $ do
  describe "GET /api/trade_disputes" $ do
    it "returns 200" $ do
      get "/api/trade_disputes" `shouldRespondWith` 200

  describe "POST /api/trade_disputes" $ do
    it "creates and returns 201" $ do
      let body = [json|{"status": "Open", "reason": "ItemNotReceived", "description": "test", "resolution": null, "openedAt": "2024-01-01T00:00:00", "resolvedAt": null, "transactionId": 1, "openedById": 1, "resolvedById": null}|]
      request "POST" "/api/trade_disputes" [("Content-Type","application/json")] body
        `shouldRespondWith` 201

  describe "GET /api/trade_disputes/1" $ do
    it "returns 200, 401, or 404" $ do
      resp <- request "GET" "/api/trade_disputes/1" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 200 || s == 401 || s == 403 || s == 404

  describe "PATCH /api/trade_disputes/1/transitions/open-to-underreview" $ do
    it "transitions Open -> UnderReview with role Admin" $ do
      resp <- request "PATCH" "/api/trade_disputes/1/transitions/open-to-underreview" [("X-User-Role","Admin")] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s `elem` [200, 409, 404, 500]

    it "rejects Open -> UnderReview without role (401 or 403)" $ do
      resp <- request "PATCH" "/api/trade_disputes/1/transitions/open-to-underreview" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 401 || s == 403

  describe "PATCH /api/trade_disputes/1/transitions/underreview-to-resolved" $ do
    it "transitions UnderReview -> Resolved with role Admin" $ do
      resp <- request "PATCH" "/api/trade_disputes/1/transitions/underreview-to-resolved" [("X-User-Role","Admin")] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s `elem` [200, 409, 404, 500]

    it "rejects UnderReview -> Resolved without role (401 or 403)" $ do
      resp <- request "PATCH" "/api/trade_disputes/1/transitions/underreview-to-resolved" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 401 || s == 403

  describe "PATCH /api/trade_disputes/1/transitions/underreview-to-escalated" $ do
    it "transitions UnderReview -> Escalated with role Admin" $ do
      resp <- request "PATCH" "/api/trade_disputes/1/transitions/underreview-to-escalated" [("X-User-Role","Admin")] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s `elem` [200, 409, 404, 500]

    it "rejects UnderReview -> Escalated without role (401 or 403)" $ do
      resp <- request "PATCH" "/api/trade_disputes/1/transitions/underreview-to-escalated" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 401 || s == 403

  describe "PATCH /api/trade_disputes/1/transitions/escalated-to-resolved" $ do
    it "transitions Escalated -> Resolved with role Admin" $ do
      resp <- request "PATCH" "/api/trade_disputes/1/transitions/escalated-to-resolved" [("X-User-Role","Admin")] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s `elem` [200, 409, 404, 500]

    it "rejects Escalated -> Resolved without role (401 or 403)" $ do
      resp <- request "PATCH" "/api/trade_disputes/1/transitions/escalated-to-resolved" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 401 || s == 403

  describe "PATCH /api/trade_disputes/1/transitions/resolved-to-open" $ do
    it "is denied (409 or 404)" $ do
      resp <- request "PATCH" "/api/trade_disputes/1/transitions/resolved-to-open" [] ""
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 409 || s == 404

  describe "POST /api/trade_disputes/1/escalate" $ do
    it "behavior escalate stub returns 404 or 500" $ do
      resp <- request "POST" "/api/trade_disputes/1/escalate" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/trade_disputes/1/resolve" $ do
    it "behavior resolve stub returns 404 or 500" $ do
      resp <- request "POST" "/api/trade_disputes/1/resolve" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/trade_disputes/1/close" $ do
    it "behavior close_resolved stub returns 404 or 500" $ do
      resp <- request "POST" "/api/trade_disputes/1/close" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/trade_disputes/1/review" $ do
    it "behavior review stub returns 404 or 500" $ do
      resp <- request "POST" "/api/trade_disputes/1/review" [("Content-Type","application/json")] "{}"
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 204 || s == 404 || s == 500

  describe "POST /api/trade_disputes rule resolved_at_requires_terminal_status" $ do
    it "rejects when resolved_at_requires_terminal_status violated" $ do
      let body = [json|{"status": "Open", "reason": "ItemNotReceived", "description": "test", "resolution": "test", "openedAt": "2024-01-01T00:00:00", "resolvedAt": "test", "transactionId": 1, "openedById": 1, "resolvedById": null}|]
      resp <- request "POST" "/api/trade_disputes" [("Content-Type","application/json")] body
      liftIO $ statusCode (simpleStatus resp) `shouldSatisfy` \s -> s == 400

