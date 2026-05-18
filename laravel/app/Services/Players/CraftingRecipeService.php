<?php

namespace App\Services\Players;

use App\Models\Players\CraftingRecipe;

class CraftingRecipeService
{
    public function create(array $data): CraftingRecipe
    {
        throw new \LogicException('Not implemented');
    }

    public function update(CraftingRecipe $craftingRecipe, array $data): CraftingRecipe
    {
        throw new \LogicException('Not implemented');
    }
    public function canCraft(int $id): bool
    {
        $craftingRecipe = CraftingRecipe::findOrFail($id);
        $result = $craftingRecipe->canCraft($player_id);
        $craftingRecipe->save();
        return $result;
    }

    public function executeCraft(int $id, $player_id): void
    {
        $craftingRecipe = CraftingRecipe::findOrFail($id);
        $craftingRecipe->executeCraft($player_id);
        $craftingRecipe->save();
    }

    public function disable(int $id): void
    {
        $craftingRecipe = CraftingRecipe::findOrFail($id);
        $craftingRecipe->disable();
        $craftingRecipe->save();
    }

    public function enable(int $id): void
    {
        $craftingRecipe = CraftingRecipe::findOrFail($id);
        $craftingRecipe->enable();
        $craftingRecipe->save();
    }
}
