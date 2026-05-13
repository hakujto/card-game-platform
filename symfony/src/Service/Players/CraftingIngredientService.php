<?php

namespace App\Service\Players;

use App\Entity\Players\CraftingIngredient;
use App\Repository\Players\CraftingIngredientRepository;

class CraftingIngredientService
{
    public function __construct(
        private CraftingIngredientRepository $repository,
    ) {}

    public function create(array $data): CraftingIngredient
    {
        throw new \LogicException('Not implemented');
    }

    public function update(CraftingIngredient $entity, array $data): CraftingIngredient
    {
        throw new \LogicException('Not implemented');
    }

}
