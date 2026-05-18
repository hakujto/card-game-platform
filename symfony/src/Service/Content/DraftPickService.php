<?php

namespace App\Service\Content;

use App\Entity\Content\DraftPick;
use App\Repository\Content\DraftPickRepository;

class DraftPickService
{
    public function __construct(
        private DraftPickRepository $repository,
    ) {}

    public function create(array $data): DraftPick
    {
        throw new \LogicException('Not implemented');
    }

    public function update(DraftPick $entity, array $data): DraftPick
    {
        throw new \LogicException('Not implemented');
    }

    public function isFirstPick(int $id): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('DraftPick not found: ' . $id);
        $result = $entity->isFirstPick();
        $this->repository->save($entity, flush: true);
        return $result;
    }
}
