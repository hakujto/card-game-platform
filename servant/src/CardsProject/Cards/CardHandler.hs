{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Cards.CardHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Cards.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple

type CardAPI
  =    "api" :> "cards" :> Get '[JSON] [Card]
  :<|> "api" :> "cards" :> ReqBody '[JSON] NewCard :> PostCreated '[JSON] Card
  :<|> "api" :> "cards" :> Capture "id" Int :> Get '[JSON] Card
  :<|> "api" :> "cards" :> Capture "id" Int :> ReqBody '[JSON] NewCard :> Put '[JSON] Card
  :<|> "api" :> "cards" :> Capture "id" Int :> ReqBody '[JSON] NewCard :> Patch '[JSON] Card
  :<|> "api" :> "cards" :> Capture "id" Int :> DeleteNoContent

cardServer :: Server CardAPI
cardServer = listAll :<|> create :<|> getOne :<|> update :<|> partialUpdate :<|> delete
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, set_id, rulings_id, abilities_id FROM cards" :: IO [Card]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO cards (name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, set_id, rulings_id, abilities_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" body
        rowId <- lastInsertRowId conn
        rows <- query conn "SELECT id, name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, set_id, rulings_id, abilities_id FROM cards WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [Card]
        return $ case rows of { (r:_) -> Just r; [] -> Nothing }
      case mRow of
        Just r  -> return r
        Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, set_id, rulings_id, abilities_id FROM cards WHERE id = ?" (Only eid) :: IO [Card]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE cards SET name = ?, card_type = ?, rarity = ?, mana_cost = ?, mana_colors = ?, attack = ?, defense = ?, loyalty = ?, description = ?, flavor_text = ?, image_url = ?, artist_name = ?, legal_formats = ?, is_banned = ?, is_restricted = ?, power_level = ?, set_id = ?, rulings_id = ?, abilities_id = ? WHERE id = ?" bodyRow
        query conn "SELECT id, name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, set_id, rulings_id, abilities_id FROM cards WHERE id = ?" (Only eid) :: IO [Card]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM cards WHERE id = ?" (Only eid)
      return NoContent

