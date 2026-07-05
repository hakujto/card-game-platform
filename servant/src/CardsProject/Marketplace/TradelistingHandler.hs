{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Marketplace.TradeListingHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Marketplace.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple
import Database.SQLite.Simple.ToField (toField)
import qualified CardsProject.Marketplace.TradeListingService as TradeListingSvc
import qualified Data.ByteString.Lazy.Char8
import Data.Text (Text)
import Control.Exception (catch, IOException)
import Data.Aeson (Object)
import Data.Text (Text)

type TradeListingAPI
  =    "api" :> "trade_listings" :> QueryParam "q" Text :> Get '[JSON] [TradeListing]
  :<|> "api" :> "trade_listings" :> ReqBody '[JSON] NewTradeListing :> PostCreated '[JSON] TradeListing
  :<|> "api" :> "trade_listings" :> Capture "id" Int :> Get '[JSON] TradeListing
  :<|> "api" :> "trade_listings" :> Capture "id" Int :> ReqBody '[JSON] NewTradeListing :> Patch '[JSON] TradeListing
  :<|> "api" :> "trade_listings" :> Capture "id" Int :> "close" :> PostNoContent
  :<|> "api" :> "trade_listings" :> Capture "id" Int :> "extend" :> ReqBody '[JSON] Object :> PatchNoContent
  :<|> "api" :> "trade_listings" :> Capture "id" Int :> "cancel" :> DeleteNoContent
  :<|> "api" :> "trade_listings" :> Capture "id" Int :> "expired" :> Get '[JSON] Bool
  :<|> "api" :> "trade_listings" :> Capture "id" Int :> "finalize" :> Header "X-User-Role" Text :> PostNoContent
  :<|> "api" :> "trade_listings" :> Capture "id" Int :> "transitions" :> "pending-to-active" :> Header "X-User-Role" Text :> Patch '[JSON] TradeListing
  :<|> "api" :> "trade_listings" :> Capture "id" Int :> "transitions" :> "active-to-sold" :> Patch '[JSON] TradeListing
  :<|> "api" :> "trade_listings" :> Capture "id" Int :> "transitions" :> "active-to-expired" :> Patch '[JSON] TradeListing
  :<|> "api" :> "trade_listings" :> Capture "id" Int :> "transitions" :> "active-to-cancelled" :> Header "X-User-Role" Text :> Patch '[JSON] TradeListing
  :<|> "api" :> "trade_listings" :> Capture "id" Int :> "transitions" :> "sold-to-active" :> Patch '[JSON] TradeListing
  :<|> "api" :> "trade_listings" :> Capture "id" Int :> "transitions" :> "expired-to-active" :> Patch '[JSON] TradeListing

tradeListingServer :: Server TradeListingAPI
tradeListingServer = listAll
  :<|> create
  :<|> getOne
  :<|> partialUpdate
  :<|> behaviorClose
  :<|> behaviorExtend
  :<|> behaviorCancel
  :<|> behaviorIsExpired
  :<|> behaviorFinalizeAuction
  :<|> transitionHandlerPendingToActive
  :<|> transitionHandlerActiveToSold
  :<|> transitionHandlerActiveToExpired
  :<|> transitionHandlerActiveToCancelled
  :<|> transitionHandlerSoldToActive
  :<|> transitionHandlerExpiredToActive
  where
    listAll mq = liftIO $ withDb $ \conn -> case mq of
      Nothing -> query_ conn "SELECT id, public_id, status, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, description, created_at, expires_at, seller_id, card_id FROM trade_listings" :: IO [TradeListing]
      Just q  -> let qp = "%" <> q <> "%" in
        query conn "SELECT id, public_id, status, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, description, created_at, expires_at, seller_id, card_id FROM trade_listings WHERE description LIKE ?" (Only qp) :: IO [TradeListing]

    create body = do
      case TradeListingSvc.validateTradeListing body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          mRow <- liftIO $ withDb $ \conn -> do
            execute conn "INSERT INTO trade_listings (public_id, status, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, description, created_at, expires_at, seller_id, card_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" validBody
            rowId <- lastInsertRowId conn
            rows <- query conn "SELECT id, public_id, status, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, description, created_at, expires_at, seller_id, card_id FROM trade_listings WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [TradeListing]
            return $ case rows of { (r:_) -> Just r; [] -> Nothing }
          case mRow of
            Just r  -> return r
            Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, public_id, status, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, description, created_at, expires_at, seller_id, card_id FROM trade_listings WHERE id = ?" (Only eid) :: IO [TradeListing]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate eid body = do
      case TradeListingSvc.validateTradeListing body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          rows <- liftIO $ withDb $ \conn -> do
            let bodyRow = [toField (bTradeListingPublicId validBody), toField (bTradeListingListingType validBody), toField (bTradeListingAskingPrice validBody), toField (bTradeListingAuctionStartPrice validBody), toField (bTradeListingAuctionCurrentBid validBody), toField (bTradeListingAuctionEndTime validBody), toField (bTradeListingFoil validBody), toField (bTradeListingCondition validBody), toField (bTradeListingQuantity validBody), toField (bTradeListingDescription validBody), toField (bTradeListingExpiresAt validBody), toField (bTradeListingSellerId validBody), toField (bTradeListingCardId validBody), toField eid]
            execute conn "UPDATE trade_listings SET public_id = ?, listing_type = ?, asking_price = ?, auction_start_price = ?, auction_current_bid = ?, auction_end_time = ?, foil = ?, condition = ?, quantity = ?, description = ?, expires_at = ?, seller_id = ?, card_id = ? WHERE id = ?" bodyRow
            query conn "SELECT id, public_id, status, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, description, created_at, expires_at, seller_id, card_id FROM trade_listings WHERE id = ?" (Only eid) :: IO [TradeListing]
          case rows of
            (r:_) -> return r
            []    -> throwError err404

    behaviorClose eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, public_id, status, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, description, created_at, expires_at, seller_id, card_id FROM trade_listings WHERE id = ?" (Only eid) :: IO [TradeListing]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> TradeListingSvc.close eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorExtend eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, public_id, status, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, description, created_at, expires_at, seller_id, card_id FROM trade_listings WHERE id = ?" (Only eid) :: IO [TradeListing]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> TradeListingSvc.extend eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorCancel eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, public_id, status, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, description, created_at, expires_at, seller_id, card_id FROM trade_listings WHERE id = ?" (Only eid) :: IO [TradeListing]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> TradeListingSvc.cancel eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorIsExpired eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, public_id, status, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, description, created_at, expires_at, seller_id, card_id FROM trade_listings WHERE id = ?" (Only eid) :: IO [TradeListing]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> TradeListingSvc.is_expired eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

    behaviorFinalizeAuction eid mRole = do
      let allowedRoles = ["admin", "seller"] :: [Text]
      case mRole of
        Nothing   -> throwError err401
        Just role -> if role `notElem` allowedRoles
          then throwError err403
          else return ()
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, public_id, status, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, description, created_at, expires_at, seller_id, card_id FROM trade_listings WHERE id = ?" (Only eid) :: IO [TradeListing]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> TradeListingSvc.finalize_auction eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    transitionHandlerPendingToActive eid mRole = do
      let allowedRoles = ["Seller"] :: [Text]
      case mRole of
        Nothing   -> throwError err401
        Just role -> if role `notElem` allowedRoles
          then throwError err403
          else return ()
      result <- liftIO $ (TradeListingSvc.transitionPendingToActive eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerActiveToSold eid = do
      result <- liftIO $ (TradeListingSvc.transitionActiveToSold eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerActiveToExpired eid = do
      result <- liftIO $ (TradeListingSvc.transitionActiveToExpired eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerActiveToCancelled eid mRole = do
      let allowedRoles = ["Seller", "Admin"] :: [Text]
      case mRole of
        Nothing   -> throwError err401
        Just role -> if role `notElem` allowedRoles
          then throwError err403
          else return ()
      result <- liftIO $ (TradeListingSvc.transitionActiveToCancelled eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerSoldToActive eid = do
      result <- liftIO $ (TradeListingSvc.transitionSoldToActive eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

    transitionHandlerExpiredToActive eid = do
      result <- liftIO $ (TradeListingSvc.transitionExpiredToActive eid >>= (return . Right))
        `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
      case result of
        Right r -> return r
        Left msg ->
          if "not allowed" `elem` words msg
            then throwError $ err409 { errBody = "Transition not allowed" }
            else throwError $ err404 { errBody = "Not found or precondition failed" }

