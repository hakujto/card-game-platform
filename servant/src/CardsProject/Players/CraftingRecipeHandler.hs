{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Players.CraftingRecipeHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Players.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple
import Database.SQLite.Simple.ToField (toField)
import qualified CardsProject.Players.CraftingRecipeService as CraftingRecipeSvc
import qualified Data.ByteString.Lazy.Char8
import Control.Exception (catch, IOException)
import Data.Aeson (Object)
import Data.Text (Text)

type CraftingRecipeAPI
  =    "api" :> "crafting_recipes" :> Get '[JSON] [CraftingRecipe]
  :<|> "api" :> "crafting_recipes" :> ReqBody '[JSON] NewCraftingRecipe :> PostCreated '[JSON] CraftingRecipe
  :<|> "api" :> "crafting_recipes" :> Capture "id" Int :> Get '[JSON] CraftingRecipe
  :<|> "api" :> "crafting_recipes" :> Capture "id" Int :> ReqBody '[JSON] NewCraftingRecipe :> Put '[JSON] CraftingRecipe
  :<|> "api" :> "crafting_recipes" :> Capture "id" Int :> ReqBody '[JSON] NewCraftingRecipe :> Patch '[JSON] CraftingRecipe
  :<|> "api" :> "crafting_recipes" :> Capture "id" Int :> "can-craft" :> Get '[JSON] Bool
  :<|> "api" :> "crafting_recipes" :> Capture "id" Int :> "craft" :> ReqBody '[JSON] Object :> PostNoContent
  :<|> "api" :> "crafting_recipes" :> Capture "id" Int :> "disable" :> PostNoContent
  :<|> "api" :> "crafting_recipes" :> Capture "id" Int :> "enable" :> PostNoContent

craftingRecipeServer :: Server CraftingRecipeAPI
craftingRecipeServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> behaviorCanCraft
  :<|> behaviorExecuteCraft
  :<|> behaviorDisable
  :<|> behaviorEnable
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, dust_cost, is_available, result_card_id FROM crafting_recipes" :: IO [CraftingRecipe]

    create body = do
      case CraftingRecipeSvc.validateCraftingRecipe body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          mRow <- liftIO $ withDb $ \conn -> do
            execute conn "INSERT INTO crafting_recipes (dust_cost, is_available, result_card_id) VALUES (?, ?, ?)" validBody
            rowId <- lastInsertRowId conn
            rows <- query conn "SELECT id, dust_cost, is_available, result_card_id FROM crafting_recipes WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [CraftingRecipe]
            return $ case rows of { (r:_) -> Just r; [] -> Nothing }
          case mRow of
            Just r  -> return r
            Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, dust_cost, is_available, result_card_id FROM crafting_recipes WHERE id = ?" (Only eid) :: IO [CraftingRecipe]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      case CraftingRecipeSvc.validateCraftingRecipe body of
        Left err -> throwError $ err400 { errBody = "Validation failed: " <> (Data.ByteString.Lazy.Char8.pack err) }
        Right validBody -> do
          rows <- liftIO $ withDb $ \conn -> do
            let bodyRow = [toField (bCraftingRecipeDustCost validBody), toField (bCraftingRecipeIsAvailable validBody), toField (bCraftingRecipeResultCardId validBody), toField eid]
            execute conn "UPDATE crafting_recipes SET dust_cost = ?, is_available = ?, result_card_id = ? WHERE id = ?" bodyRow
            query conn "SELECT id, dust_cost, is_available, result_card_id FROM crafting_recipes WHERE id = ?" (Only eid) :: IO [CraftingRecipe]
          case rows of
            (r:_) -> return r
            []    -> throwError err404

    partialUpdate = update

    behaviorCanCraft eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, dust_cost, is_available, result_card_id FROM crafting_recipes WHERE id = ?" (Only eid) :: IO [CraftingRecipe]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> CraftingRecipeSvc.can_craft eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right result -> return result
            Left _       -> throwError err500

    behaviorExecuteCraft eid _body = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, dust_cost, is_available, result_card_id FROM crafting_recipes WHERE id = ?" (Only eid) :: IO [CraftingRecipe]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> CraftingRecipeSvc.execute_craft eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorDisable eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, dust_cost, is_available, result_card_id FROM crafting_recipes WHERE id = ?" (Only eid) :: IO [CraftingRecipe]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> CraftingRecipeSvc.disable eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

    behaviorEnable eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, dust_cost, is_available, result_card_id FROM crafting_recipes WHERE id = ?" (Only eid) :: IO [CraftingRecipe]
      case rows of
        []    -> throwError err404
        (_:_) -> do
          eResult <- liftIO $ (Right <$> CraftingRecipeSvc.enable eid)
            `Control.Exception.catch` (\e -> return . Left $ show (e :: IOError))
          case eResult of
            Right _ -> return NoContent
            Left _  -> throwError err500

