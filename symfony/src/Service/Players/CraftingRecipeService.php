<?php

namespace App\Service\Players;

use App\Entity\Players\CraftingRecipe;
use App\Repository\Players\CraftingRecipeRepository;

class CraftingRecipeService
{
    public function __construct(
        private CraftingRecipeRepository $repository,
    ) {}

    public function create(array $data): CraftingRecipe
    {
        throw new \LogicException('Not implemented');
    }

    public function update(CraftingRecipe $entity, array $data): CraftingRecipe
    {
        throw new \LogicException('Not implemented');
    }

}
