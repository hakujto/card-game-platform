{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Players.CraftingRecipeService where

import CardsProject.Players.Types

-- Domain service stub for CraftingRecipe
validateCraftingRecipe :: NewCraftingRecipe -> Either String NewCraftingRecipe
validateCraftingRecipe body = Right body

