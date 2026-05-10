{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
module CardsProject.Players.CraftingIngredientHandler where

import Control.Monad.IO.Class (liftIO)
import Servant hiding (Stream)
import CardsProject.Players.Types
import CardsProject.Db (withDb)
import Database.SQLite.Simple

type CraftingIngredientAPI
  =    "api" :> "crafting_ingredients" :> Get '[JSON] [CraftingIngredient]
  :<|> "api" :> "crafting_ingredients" :> ReqBody '[JSON] NewCraftingIngredient :> PostCreated '[JSON] CraftingIngredient
  :<|> "api" :> "crafting_ingredients" :> Capture "id" Int :> Get '[JSON] CraftingIngredient
  :<|> "api" :> "crafting_ingredients" :> Capture "id" Int :> ReqBody '[JSON] NewCraftingIngredient :> Put '[JSON] CraftingIngredient
  :<|> "api" :> "crafting_ingredients" :> Capture "id" Int :> ReqBody '[JSON] NewCraftingIngredient :> Patch '[JSON] CraftingIngredient
  :<|> "api" :> "crafting_ingredients" :> Capture "id" Int :> DeleteNoContent

craftingIngredientServer :: Server CraftingIngredientAPI
craftingIngredientServer = listAll :<|> create :<|> getOne :<|> update :<|> partialUpdate :<|> delete
  where
    listAll = liftIO $ withDb $ \conn ->
      query_ conn "SELECT id, quantity, recipe_id, card_id FROM crafting_ingredients" :: IO [CraftingIngredient]

    create body = do
      mRow <- liftIO $ withDb $ \conn -> do
        execute conn "INSERT INTO crafting_ingredients (quantity, recipe_id, card_id) VALUES (?, ?, ?)" body
        rowId <- lastInsertRowId conn
        rows <- query conn "SELECT id, quantity, recipe_id, card_id FROM crafting_ingredients WHERE id = ?" (Only (fromIntegral rowId :: Int)) :: IO [CraftingIngredient]
        return $ case rows of { (r:_) -> Just r; [] -> Nothing }
      case mRow of
        Just r  -> return r
        Nothing -> throwError err500

    getOne eid = do
      rows <- liftIO $ withDb $ \conn ->
        query conn "SELECT id, quantity, recipe_id, card_id FROM crafting_ingredients WHERE id = ?" (Only eid) :: IO [CraftingIngredient]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    update eid body = do
      rows <- liftIO $ withDb $ \conn -> do
        let bodyRow = toRow body ++ toRow (Only eid)
        execute conn "UPDATE crafting_ingredients SET quantity = ?, recipe_id = ?, card_id = ? WHERE id = ?" bodyRow
        query conn "SELECT id, quantity, recipe_id, card_id FROM crafting_ingredients WHERE id = ?" (Only eid) :: IO [CraftingIngredient]
      case rows of
        (r:_) -> return r
        []    -> throwError err404

    partialUpdate = update

    delete eid = do
      liftIO $ withDb $ \conn ->
        execute conn "DELETE FROM crafting_ingredients WHERE id = ?" (Only eid)
      return NoContent

