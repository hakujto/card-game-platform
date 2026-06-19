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
import qualified Data.ByteString.Lazy.Char8
import Data.Text (Text)
import Control.Exception (catch, IOException)
import Data.Aeson (Object)
import Data.Text (Text)

type TradeDisputeAPI
  =    "api" :> "trade_disputes" :> Get '[JSON] [TradeDispute]
  :<|> "api" :> "trade_disputes" :> ReqBody '[JSON] NewTradeDispute :> PostCreated '[JSON] TradeDispute
  :<|> "api" :> "trade_disputes" :> Capture "id" Int :> Get '[JSON] TradeDispute
  :<|> "api" :> "trade_disputes" :> Capture "id" Int :> "escalate" :> PostNoContent
  :<|> "api" :> "trade_disputes" :> Capture "id" Int :> "resolve" :> ReqBody '[JSON] Object :> PostNoContent
  :<|> "api" :> "trade_disputes" :> Capture "id" Int :> "close" :> PostNoContent
  :<|> "api" :> "trade_disputes" :> Capture "id" Int :> "review" :> PostNoContent
  :<|> "api" :> "trade_disputes" :> Capture "id" Int :> "transitions" :> "open-to-underreview" :> Header "X-User-Role" Text :> Patch '[JSON] TradeDispute
  :<|> "api" :> "trade_disputes" :> Capture "id" Int :> "transitions" :> "underreview-to-resolved" :> Header "X-User-Role" Text :> Patch '[JSON] TradeDispute
  :<|> "api" :> "trade_disputes" :> Capture "id" Int :> "transitions" :> "underreview-to-escalated" :> Header "X-User-Role" Text :> Patch '[JSON] TradeDispute
  :<|> "api" :> "trade_disputes" :> Capture "id" Int :> "transitions" :> "escalated-to-resolved" :> Header "X-User-Role" Text :> Patch '[JSON] TradeDispute
  :<|> "api" :> "trade_disputes" :> Capture "id" Int :> "transitions" :> "resolved-to-open" :> Patch '[JSON] TradeDispute

tradeDisputeServer :: Server TradeDisputeAPI
tradeDisputeServer = listAll
  :<|> create
  :<|> getOne
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
      case TradeDisputeSvc.validateTradeDispute body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          mRow <- liftIO $ withDb $ \conn -> do
            execute conn "INSERT INTO trade_disputes (status, reason, description, resolution, opened_at, resolved_at, transaction_id, opened_by_id, resolved_by_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)" validBody
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

    behaviorEscalate eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, status, reason, description, resolution, opened_at, resolved_at, transaction_id, opened_by_id, resolved_by_id FROM trade_disputes WHERE id = ?" (Only eid) :: IO [TradeDispute]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> TradeDisputeSvc.escalate eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorResolve eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, status, reason, description, resolution, opened_at, resolved_at, transaction_id, opened_by_id, resolved_by_id FROM trade_disputes WHERE id = ?" (Only eid) :: IO [TradeDispute]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> TradeDisputeSvc.resolve eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorCloseResolved eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, status, reason, description, resolution, opened_at, resolved_at, transaction_id, opened_by_id, resolved_by_id FROM trade_disputes WHERE id = ?" (Only eid) :: IO [TradeDispute]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> TradeDisputeSvc.close_resolved eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorReview eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, status, reason, description, resolution, opened_at, resolved_at, transaction_id, opened_by_id, resolved_by_id FROM trade_disputes WHERE id = ?" (Only eid) :: IO [TradeDispute]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> TradeDisputeSvc.review eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    transitionHandlerOpenToUnderReview eid mRole = do
      let allowedRoles = ["Admin", "Moderator"] :: [Text]
      case mRole of
        Nothing   -> throwError err401
        Just role -> if role `notElem` allowedRoles
          then throwError err403
          else return ()
      result <- liftIO $ (TradeDisputeSvc.transitionOpenToUnderReview eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerUnderReviewToResolved eid mRole = do
      let allowedRoles = ["Admin", "Moderator"] :: [Text]
      case mRole of
        Nothing   -> throwError err401
        Just role -> if role `notElem` allowedRoles
          then throwError err403
          else return ()
      result <- liftIO $ (TradeDisputeSvc.transitionUnderReviewToResolved eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerUnderReviewToEscalated eid mRole = do
      let allowedRoles = ["Admin"] :: [Text]
      case mRole of
        Nothing   -> throwError err401
        Just role -> if role `notElem` allowedRoles
          then throwError err403
          else return ()
      result <- liftIO $ (TradeDisputeSvc.transitionUnderReviewToEscalated eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerEscalatedToResolved eid mRole = do
      let allowedRoles = ["Admin"] :: [Text]
      case mRole of
        Nothing   -> throwError err401
        Just role -> if role `notElem` allowedRoles
          then throwError err403
          else return ()
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

