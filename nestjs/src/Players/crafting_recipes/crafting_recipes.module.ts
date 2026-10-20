import { Module } from '@nestjs/common';
import { CraftingRecipeController } from './crafting_recipes.controller';
import { CraftingRecipeService } from './crafting_recipe.service';

@Module({
  controllers: [CraftingRecipeController],
  providers: [CraftingRecipeService],
})
export class CraftingRecipeModule {}
