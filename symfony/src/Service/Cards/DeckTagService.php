<?php

namespace App\Service\Cards;

use App\Entity\Cards\DeckTag;
use App\Repository\Cards\DeckTagRepository;

class DeckTagService
{
    public function __construct(
        private DeckTagRepository $repository,
    ) {}

    public function create(array $data): DeckTag
    {
        throw new \LogicException('Not implemented');
    }

    public function update(DeckTag $entity, array $data): DeckTag
    {
        throw new \LogicException('Not implemented');
    }

    public function rename(int $id, $newName): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('DeckTag not found: ' . $id);
        $entity->rename($newName);
        $this->repository->save($entity, flush: true);
    }

    public function mergeInto(int $id, $targetTagId): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('DeckTag not found: ' . $id);
        $entity->mergeInto($targetTagId);
        $this->repository->save($entity, flush: true);
    }
}
