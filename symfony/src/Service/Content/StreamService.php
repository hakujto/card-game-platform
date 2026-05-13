<?php

namespace App\Service\Content;

use App\Entity\Content\Stream;
use App\Repository\Content\StreamRepository;

class StreamService
{
    public function __construct(
        private StreamRepository $repository,
    ) {}

    public function create(array $data): Stream
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Stream $entity, array $data): Stream
    {
        throw new \LogicException('Not implemented');
    }

    public function goLive(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Stream not found: ' . $id);
        $entity->goLive();
        $this->repository->save($entity, flush: true);
    }

    public function end(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Stream not found: ' . $id);
        $entity->end();
        $this->repository->save($entity, flush: true);
    }

    public function updateViewerPeak(int $id, $count): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Stream not found: ' . $id);
        $entity->updateViewerPeak($count);
        $this->repository->save($entity, flush: true);
    }
}
