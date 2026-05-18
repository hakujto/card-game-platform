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

type CraftingRecipeAPI
  =    "api" :> "crafting_recipes" :> Get '[JSON] [CraftingRecipe]
  :<|> "api" :> "crafting_recipes" :> ReqBody '[JSON] NewCraftingRecipe :> PostCreated '[JSON] CraftingRecipe
  :<|> "api" :> "crafting_recipes" :> Capture "id" Int :> Get '[JSON] CraftingRecipe
  :<|> "api" :> "crafting_recipes" :> Capture "id" Int :> ReqBody '[JSON] NewCraftingRecipe :> Put '[JSON] CraftingRecipe
  :<|> "api" :> "crafting_recipes" :> Capture "id" Int :> ReqBody '[JSON] NewCraftingRecipe :> Patch '[JSON] CraftingRecipe
  :<|> "api" :> "crafting_recipes" :> Capture "id" Int :> DeleteNoContent

craftingRecipeServer :: Server CraftingRecipeAPI
craftingRecipeServer = listAll
  :<|> create
  :<|> getOne
  :<|> update
  :<|> partialUpdate
  :<|> delete
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, dust_cost, is_available, result_card_id FROM crafting_recipes" :: IO [CraftingRecipe]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO crafting_recipes (dust_cost, is_available, result_card_id) VALUES (?, ?, ?)" body
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
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE crafting_recipes SET dust_cost = ?, is_available = ?, result_card_id = ? WHERE id = ?" bodyRow
        query conn "SELECT id, dust_cost, is_available, result_card_id FROM crafting_recipes WHERE id = ?" (Only eid) :: IO [CraftingRecipe]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM crafting_recipes WHERE id = ?" (Only eid)
      return NoContent

