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
import qualified CardsProject.Cards.CardService as CardSvc
import Data.Aeson (Object)
import Data.Text (Text)

type CardAPI
  =    "api" :> "cards" :> Get '[JSON] [Card]
  :<|> "api" :> "cards" :> ReqBody '[JSON] NewCard :> PostCreated '[JSON] Card
  :<|> "api" :> "cards" :> Capture "id" Int :> Get '[JSON] Card
  :<|> "api" :> "cards" :> Capture "id" Int :> ReqBody '[JSON] NewCard :> Put '[JSON] Card
  :<|> "api" :> "cards" :> Capture "id" Int :> ReqBody '[JSON] NewCard :> Patch '[JSON] Card
  :<|> "api" :> "cards" :> Capture "id" Int :> DeleteNoContent
  :<|> "api" :> "cards" :> Capture "id" Int :> "ban" :> Post '[JSON] NoContent
  :<|> "api" :> "cards" :> Capture "id" Int :> "unban" :> Post '[JSON] NoContent
  :<|> "api" :> "cards" :> Capture "id" Int :> "restrict" :> Post '[JSON] NoContent
  :<|> "api" :> "cards" :> Capture "id" Int :> "unrestrict" :> Post '[JSON] NoContent
  :<|> "api" :> "cards" :> Capture "id" Int :> "value" :> Get '[JSON] Text
  :<|> "api" :> "cards" :> Capture "id" Int :> "rarity-bonus" :> ReqBody '[JSON] Object :> Post '[JSON] Text
  :<|> "api" :> "cards" :> Capture "id" Int :> "legal" :> Get '[JSON] Bool

cardServer :: Server CardAPI
cardServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> delete
  :<|> behaviorBan
  :<|> behaviorUnban
  :<|> behaviorRestrict
  :<|> behaviorUnrestrict
  :<|> behaviorCalculateValue
  :<|> behaviorApplyRarityBonus
  :<|> behaviorIsLegalInFormat
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

    behaviorBan eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, set_id, rulings_id, abilities_id FROM cards WHERE id = ?" (Only eid) :: IO [Card]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ CardSvc.ban eid
          return NoContent

    behaviorUnban eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, set_id, rulings_id, abilities_id FROM cards WHERE id = ?" (Only eid) :: IO [Card]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ CardSvc.unban eid
          return NoContent

    behaviorRestrict eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, set_id, rulings_id, abilities_id FROM cards WHERE id = ?" (Only eid) :: IO [Card]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ CardSvc.restrict eid
          return NoContent

    behaviorUnrestrict eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, set_id, rulings_id, abilities_id FROM cards WHERE id = ?" (Only eid) :: IO [Card]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          liftIO $ CardSvc.unrestrict eid
          return NoContent

    behaviorCalculateValue eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, set_id, rulings_id, abilities_id FROM cards WHERE id = ?" (Only eid) :: IO [Card]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          result <- liftIO $ CardSvc.calculate_value eid
          return result

    behaviorApplyRarityBonus eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, set_id, rulings_id, abilities_id FROM cards WHERE id = ?" (Only eid) :: IO [Card]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          result <- liftIO $ CardSvc.apply_rarity_bonus eid
          return result

    behaviorIsLegalInFormat eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, set_id, rulings_id, abilities_id FROM cards WHERE id = ?" (Only eid) :: IO [Card]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          result <- liftIO $ CardSvc.is_legal_in_format eid
          return result

