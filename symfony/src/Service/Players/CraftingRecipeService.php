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

    public function canCraft(int $id, $playerId): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('CraftingRecipe not found: ' . $id);
        $result = $entity->canCraft($playerId);
        $this->repository->save($entity, flush: true);
        return $result;
    }

    public function executeCraft(int $id, $playerId): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('CraftingRecipe not found: ' . $id);
        $entity->executeCraft($playerId);
        $this->repository->save($entity, flush: true);
    }

    public function disable(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('CraftingRecipe not found: ' . $id);
        $entity->disable();
        $this->repository->save($entity, flush: true);
    }

    public function enable(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('CraftingRecipe not found: ' . $id);
        $entity->enable();
        $this->repository->save($entity, flush: true);
    }
}
