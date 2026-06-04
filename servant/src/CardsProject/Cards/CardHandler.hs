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
import qualified Data.ByteString.Lazy.Char8
import Control.Exception (catch, IOException)
import Data.Aeson (Object)
import Data.Text (Text)

type CardAPI
  =    "api" :> "cards" :> QueryParam "q" Text :> Get '[JSON] [Card]
  :<|> "api" :> "cards" :> ReqBody '[JSON] NewCard :> PostCreated '[JSON] Card
  :<|> "api" :> "cards" :> Capture "id" Int :> Get '[JSON] Card
  :<|> "api" :> "cards" :> Capture "id" Int :> ReqBody '[JSON] NewCard :> Put '[JSON] Card
  :<|> "api" :> "cards" :> Capture "id" Int :> ReqBody '[JSON] NewCard :> Patch '[JSON] Card
  :<|> "api" :> "cards" :> Capture "id" Int :> "ban" :> PostNoContent
  :<|> "api" :> "cards" :> Capture "id" Int :> "unban" :> PostNoContent
  :<|> "api" :> "cards" :> Capture "id" Int :> "restrict" :> PostNoContent
  :<|> "api" :> "cards" :> Capture "id" Int :> "unrestrict" :> PostNoContent
  :<|> "api" :> "cards" :> Capture "id" Int :> "value" :> Get '[JSON] Text
  :<|> "api" :> "cards" :> Capture "id" Int :> "rarity-bonus" :> ReqBody '[JSON] Object :> Post '[JSON] Text
  :<|> "api" :> "cards" :> Capture "id" Int :> "legal" :> Get '[JSON] Bool

cardServer :: Server CardAPI
cardServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> behaviorBan
  :<|> behaviorUnban
  :<|> behaviorRestrict
  :<|> behaviorUnrestrict
  :<|> behaviorCalculateValue
  :<|> behaviorApplyRarityBonus
  :<|> behaviorIsLegalInFormat
  where
    listAll mq = liftIO $ withDb $ \conn -> case mq of
      Nothing -> query_ conn "SELECT id, name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, set_id FROM cards" :: IO [Card]
      Just q  -> let qp = "%" <> q <> "%" in
        query conn "SELECT id, name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, set_id FROM cards WHERE name LIKE ? OR artist_name LIKE ?" ((qp, qp)) :: IO [Card]

    create body = do
      case CardSvc.validateCard body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          mRow <- liftIO $ withDb $ \conn -> do
            execute conn "INSERT INTO cards (name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, set_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" validBody
            rowId <- lastInsertRowId conn
            rows <- query conn "SELECT id, name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, set_id FROM cards WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [Card]
            return $ case rows of { (r:_) -> Just r; [] -> Nothing }
          case mRow of
            Just r  -> return r
            Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, set_id FROM cards WHERE id = ?" (Only eid) :: IO [Card]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      case CardSvc.validateCard body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          rows <- liftIO $ withDb $ \conn -> do
            let bodyRow = toRow validBody ++ toRow (Only eid)
            execute conn "UPDATE cards SET name = ?, card_type = ?, rarity = ?, mana_cost = ?, mana_colors = ?, attack = ?, defense = ?, loyalty = ?, description = ?, flavor_text = ?, image_url = ?, artist_name = ?, legal_formats = ?, is_banned = ?, is_restricted = ?, power_level = ?, set_id = ? WHERE id = ?" bodyRow
            query conn "SELECT id, name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, set_id FROM cards WHERE id = ?" (Only eid) :: IO [Card]
          case rows of
            (r:_) -> return r
            []    -> throwError err404

    partialUpdate = update

    behaviorBan eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, set_id FROM cards WHERE id = ?" (Only eid) :: IO [Card]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> CardSvc.ban eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorUnban eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, set_id FROM cards WHERE id = ?" (Only eid) :: IO [Card]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> CardSvc.unban eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorRestrict eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, set_id FROM cards WHERE id = ?" (Only eid) :: IO [Card]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> CardSvc.restrict eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorUnrestrict eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, set_id FROM cards WHERE id = ?" (Only eid) :: IO [Card]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> CardSvc.unrestrict eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorCalculateValue eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, set_id FROM cards WHERE id = ?" (Only eid) :: IO [Card]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> CardSvc.calculate_value eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

    behaviorApplyRarityBonus eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, set_id FROM cards WHERE id = ?" (Only eid) :: IO [Card]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> CardSvc.apply_rarity_bonus eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

    behaviorIsLegalInFormat eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, set_id FROM cards WHERE id = ?" (Only eid) :: IO [Card]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> CardSvc.is_legal_in_format eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

