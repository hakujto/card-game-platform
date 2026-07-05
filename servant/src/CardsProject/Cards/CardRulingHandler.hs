{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Cards.CardRulingHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Cards.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple
import Database.SQLite.Simple.ToField (toField)
import qualified CardsProject.Cards.CardRulingService as CardRulingSvc
import Control.Exception (catch, IOException)

type CardRulingAPI
  =    "api" :> "card_rulings" :> Get '[JSON] [CardRuling]
  :<|> "api" :> "card_rulings" :> ReqBody '[JSON] NewCardRuling :> PostCreated '[JSON] CardRuling
  :<|> "api" :> "card_rulings" :> Capture "id" Int :> Get '[JSON] CardRuling
  :<|> "api" :> "card_rulings" :> Capture "id" Int :> DeleteNoContent
  :<|> "api" :> "card_rulings" :> Capture "id" Int :> "current" :> Get '[JSON] Bool
  :<|> "api" :> "card_rulings" :> Capture "id" Int :> "supersedes" :> Get '[JSON] Bool

cardRulingServer :: Server CardRulingAPI
cardRulingServer = listAll
  :<|> create
  :<|> getOne
  :<|> delete
  :<|> behaviorIsCurrent
  :<|> behaviorSupersedesPrevious
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, ruling_text, published_at, source, card_id FROM card_rulings" :: IO [CardRuling]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO card_rulings (ruling_text, published_at, source, card_id) VALUES (?, ?, ?, ?)" body
        rowId <- lastInsertRowId conn
        rows <- query conn "SELECT id, ruling_text, published_at, source, card_id FROM card_rulings WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [CardRuling]
        return $ case rows of { (r:_) -> Just r; [] -> Nothing }
      case mRow of
        Just r  -> return r
        Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, ruling_text, published_at, source, card_id FROM card_rulings WHERE id = ?" (Only eid) :: IO [CardRuling]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM card_rulings WHERE id = ?" (Only eid)
      return NoContent

    behaviorIsCurrent eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, ruling_text, published_at, source, card_id FROM card_rulings WHERE id = ?" (Only eid) :: IO [CardRuling]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> CardRulingSvc.is_current eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

    behaviorSupersedesPrevious eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, ruling_text, published_at, source, card_id FROM card_rulings WHERE id = ?" (Only eid) :: IO [CardRuling]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> CardRulingSvc.supersedes_previous eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

