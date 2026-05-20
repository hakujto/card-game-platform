{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Marketplace.TradeDisputeHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Marketplace.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple
import qualified CardsProject.Marketplace.TradeDisputeService as TradeDisputeSvc
import Data.Text (Text)
import Control.Exception (catch, IOException)
import Data.Aeson (Object)
import Data.Text (Text)

type TradeDisputeAPI
  =    "api" :> "trade_disputes" :> Get '[JSON] [TradeDispute]
  :<|> "api" :> "trade_disputes" :> ReqBody '[JSON] NewTradeDispute :> PostCreated '[JSON] TradeDispute
  :<|> "api" :> "trade_disputes" :> Capture "id" Int :> Get '[JSON] TradeDispute
  :<|> "api" :> "trade_disputes" :> Capture "id" Int :> ReqBody '[JSON] NewTradeDispute :> Put '[JSON] TradeDispute
  :<|> "api" :> "trade_disputes" :> Capture "id" Int :> ReqBody '[JSON] NewTradeDispute :> Patch '[JSON] TradeDispute
  :<|> "api" :> "trade_disputes" :> Capture "id" Int :> DeleteNoContent
  :<|> "api" :> "trade_disputes" :> Capture "id" Int :> "escalate" :> Post '[JSON] NoContent
  :<|> "api" :> "trade_disputes" :> Capture "id" Int :> "resolve" :> ReqBody '[JSON] Object :> Post '[JSON] NoContent
  :<|> "api" :> "trade_disputes" :> Capture "id" Int :> "close" :> Post '[JSON] NoContent
  :<|> "api" :> "trade_disputes" :> Capture "id" Int :> "review" :> Post '[JSON] NoContent
  :<|> "api" :> "trade_disputes" :> Capture "id" Int :> "transitions" :> "open-to-underreview" :> Patch '[JSON] TradeDispute
  :<|> "api" :> "trade_disputes" :> Capture "id" Int :> "transitions" :> "underreview-to-resolved" :> Patch '[JSON] TradeDispute
  :<|> "api" :> "trade_disputes" :> Capture "id" Int :> "transitions" :> "underreview-to-escalated" :> Patch '[JSON] TradeDispute
  :<|> "api" :> "trade_disputes" :> Capture "id" Int :> "transitions" :> "escalated-to-resolved" :> Patch '[JSON] TradeDispute
  :<|> "api" :> "trade_disputes" :> Capture "id" Int :> "transitions" :> "resolved-to-open" :> Patch '[JSON] TradeDispute

tradeDisputeServer :: Server TradeDisputeAPI
tradeDisputeServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> delete
  :<|> behaviorEscalate
  :<|> behaviorResolve
  :<|> behaviorCloseResolved
  :<|> behaviorReview
  :<|> transitionHandlerOpenToUnderReview
  :<|> transitionHandlerUnderReviewToResolved
  :<|> transitionHandlerUnderReviewToEscalated
  :<|> transitionHandlerEscalatedToResolved
  :<|> transitionHandlerResolvedToOpen
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, status, reason, description, resolution, opened_at, resolved_at, transaction_id, opened_by_id, resolved_by_id FROM trade_disputes" :: IO [TradeDispute]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO trade_disputes (status, reason, description, resolution, opened_at, resolved_at, transaction_id, opened_by_id, resolved_by_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)" body
        rowId <- lastInsertRowId conn
        rows <- query conn "SELECT id, status, reason, description, resolution, opened_at, resolved_at, transaction_id, opened_by_id, resolved_by_id FROM trade_disputes WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [TradeDispute]
        return $ case rows of { (r:_) -> Just r; [] -> Nothing }
      case mRow of
        Just r  -> return r
        Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, status, reason, description, resolution, opened_at, resolved_at, transaction_id, opened_by_id, resolved_by_id FROM trade_disputes WHERE id = ?" (Only eid) :: IO [TradeDispute]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE trade_disputes SET status = ?, reason = ?, description = ?, resolution = ?, opened_at = ?, resolved_at = ?, transaction_id = ?, opened_by_id = ?, resolved_by_id = ? WHERE id = ?" bodyRow
        query conn "SELECT id, status, reason, description, resolution, opened_at, resolved_at, transaction_id, opened_by_id, resolved_by_id FROM trade_disputes WHERE id = ?" (Only eid) :: IO [TradeDispute]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM trade_disputes WHERE id = ?" (Only eid)
      return NoContent

    behaviorEscalate eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, status, reason, description, resolution, opened_at, resolved_at, transaction_id, opened_by_id, resolved_by_id FROM trade_disputes WHERE id = ?" (Only eid) :: IO [TradeDispute]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ TradeDisputeSvc.escalate eid
          return NoContent

    behaviorResolve eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, status, reason, description, resolution, opened_at, resolved_at, transaction_id, opened_by_id, resolved_by_id FROM trade_disputes WHERE id = ?" (Only eid) :: IO [TradeDispute]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ TradeDisputeSvc.resolve eid
          return NoContent

    behaviorCloseResolved eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, status, reason, description, resolution, opened_at, resolved_at, transaction_id, opened_by_id, resolved_by_id FROM trade_disputes WHERE id = ?" (Only eid) :: IO [TradeDispute]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ TradeDisputeSvc.close_resolved eid
          return NoContent

    behaviorReview eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, status, reason, description, resolution, opened_at, resolved_at, transaction_id, opened_by_id, resolved_by_id FROM trade_disputes WHERE id = ?" (Only eid) :: IO [TradeDispute]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ TradeDisputeSvc.review eid
          return NoContent

    transitionHandlerOpenToUnderReview eid = do
      result <- liftIO $ (TradeDisputeSvc.transitionOpenToUnderReview eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerUnderReviewToResolved eid = do
      result <- liftIO $ (TradeDisputeSvc.transitionUnderReviewToResolved eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerUnderReviewToEscalated eid = do
      result <- liftIO $ (TradeDisputeSvc.transitionUnderReviewToEscalated eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerEscalatedToResolved eid = do
      result <- liftIO $ (TradeDisputeSvc.transitionEscalatedToResolved eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerResolvedToOpen eid = do
      result <- liftIO $ (TradeDisputeSvc.transitionResolvedToOpen eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

