{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Cards.CardAbilityHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Cards.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple

type CardAbilityAPI
  =    "api" :> "card_abilities" :> Get '[JSON] [CardAbility]
  :<|> "api" :> "card_abilities" :> ReqBody '[JSON] NewCardAbility :> PostCreated '[JSON] CardAbility
  :<|> "api" :> "card_abilities" :> Capture "id" Int :> Get '[JSON] CardAbility
  :<|> "api" :> "card_abilities" :> Capture "id" Int :> ReqBody '[JSON] NewCardAbility :> Put '[JSON] CardAbility
  :<|> "api" :> "card_abilities" :> Capture "id" Int :> ReqBody '[JSON] NewCardAbility :> Patch '[JSON] CardAbility
  :<|> "api" :> "card_abilities" :> Capture "id" Int :> DeleteNoContent

cardAbilityServer :: Server CardAbilityAPI
cardAbilityServer = listAll :<|> create :<|> getOne :<|> update :<|> partialUpdate :<|> delete
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, ability_type, keyword, ability_text, timing, card_id FROM card_abilities" :: IO [CardAbility]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO card_abilities (ability_type, keyword, ability_text, timing, card_id) VALUES (?, ?, ?, ?, ?)" body
        rowId <- lastInsertRowId conn
        rows <- query conn "SELECT id, ability_type, keyword, ability_text, timing, card_id FROM card_abilities WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [CardAbility]
        return $ case rows of { (r:_) -> Just r; [] -> Nothing }
      case mRow of
        Just r  -> return r
        Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, ability_type, keyword, ability_text, timing, card_id FROM card_abilities WHERE id = ?" (Only eid) :: IO [CardAbility]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE card_abilities SET ability_type = ?, keyword = ?, ability_text = ?, timing = ?, card_id = ? WHERE id = ?" bodyRow
        query conn "SELECT id, ability_type, keyword, ability_text, timing, card_id FROM card_abilities WHERE id = ?" (Only eid) :: IO [CardAbility]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM card_abilities WHERE id = ?" (Only eid)
      return NoContent

