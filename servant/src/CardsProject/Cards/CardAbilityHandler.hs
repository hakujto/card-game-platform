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
import Database.SQLite.Simple.ToField (toField)
import qualified CardsProject.Cards.CardAbilityService as CardAbilitySvc
import qualified Data.ByteString.Lazy.Char8
import Control.Exception (catch, IOException)
import Data.Text (Text)

type CardAbilityAPI
  =    "api" :> "card_abilities" :> QueryParam "q" Text :> Get '[JSON] [CardAbility]
  :<|> "api" :> "card_abilities" :> ReqBody '[JSON] NewCardAbility :> PostCreated '[JSON] CardAbility
  :<|> "api" :> "card_abilities" :> Capture "id" Int :> Get '[JSON] CardAbility
  :<|> "api" :> "card_abilities" :> Capture "id" Int :> ReqBody '[JSON] NewCardAbility :> Put '[JSON] CardAbility
  :<|> "api" :> "card_abilities" :> Capture "id" Int :> ReqBody '[JSON] NewCardAbility :> Patch '[JSON] CardAbility
  :<|> "api" :> "card_abilities" :> Capture "id" Int :> DeleteNoContent
  :<|> "api" :> "card_abilities" :> Capture "id" Int :> "usable" :> Get '[JSON] Bool
  :<|> "api" :> "card_abilities" :> Capture "id" Int :> "describe" :> Get '[JSON] Text

cardAbilityServer :: Server CardAbilityAPI
cardAbilityServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> delete
  :<|> behaviorIsUsableAt
  :<|> behaviorDescribe
  where
    listAll mq = liftIO $ withDb $ \conn -> case mq of
      Nothing -> query_ conn "SELECT id, ability_type, keyword, ability_text, timing, card_id FROM card_abilities" :: IO [CardAbility]
      Just q  -> let qp = "%" <> q <> "%" in
        query conn "SELECT id, ability_type, keyword, ability_text, timing, card_id FROM card_abilities WHERE keyword LIKE ? OR ability_text LIKE ?" ((qp, qp)) :: IO [CardAbility]

    create body = do
      case CardAbilitySvc.validateCardAbility body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          mRow <- liftIO $ withDb $ \conn -> do
            execute conn "INSERT INTO card_abilities (ability_type, keyword, ability_text, timing, card_id) VALUES (?, ?, ?, ?, ?)" validBody
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
      case CardAbilitySvc.validateCardAbility body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          rows <- liftIO $ withDb $ \conn -> do
            let bodyRow = [toField (bCardAbilityAbilityType validBody), toField (bCardAbilityKeyword validBody), toField (bCardAbilityAbilityText validBody), toField (bCardAbilityTiming validBody), toField (bCardAbilityCardId validBody), toField eid]
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

    behaviorIsUsableAt eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, ability_type, keyword, ability_text, timing, card_id FROM card_abilities WHERE id = ?" (Only eid) :: IO [CardAbility]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> CardAbilitySvc.is_usable_at eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

    behaviorDescribe eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, ability_type, keyword, ability_text, timing, card_id FROM card_abilities WHERE id = ?" (Only eid) :: IO [CardAbility]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> CardAbilitySvc.describe eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

