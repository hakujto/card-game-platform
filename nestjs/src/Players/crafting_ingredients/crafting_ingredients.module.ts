import { Module } from '@nestjs/common';
import { CraftingIngredientController } from './crafting_ingredients.controller';

@Module({
  controllers: [CraftingIngredientController],
  providers: [],
})
export class CraftingIngredientModule {}
