<?php

namespace App\Service\Content;

use App\Entity\Content\DraftSession;
use App\Repository\Content\DraftSessionRepository;

class DraftSessionService
{
    public function __construct(
        private DraftSessionRepository $repository,
    ) {}

    public function create(array $data): DraftSession
    {
        throw new \LogicException('Not implemented');
    }

    public function update(DraftSession $entity, array $data): DraftSession
    {
        throw new \LogicException('Not implemented');
    }

    public function start(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('DraftSession not found: ' . $id);
        $entity->start();
        $this->repository->save($entity, flush: true);
    }

    public function abandon(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('DraftSession not found: ' . $id);
        $entity->abandon();
        $this->repository->save($entity, flush: true);
    }

    public function complete(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('DraftSession not found: ' . $id);
        $entity->complete();
        $this->repository->save($entity, flush: true);
    }
}
