<?php

namespace App\Service\Tournaments;

use App\Entity\Tournaments\MatchRecord;
use App\Repository\Tournaments\MatchRecordRepository;

class MatchRecordService
{
    public function __construct(
        private MatchRecordRepository $repository,
    ) {}

    public function create(array $data): MatchRecord
    {
        throw new \LogicException('Not implemented');
    }

    public function update(MatchRecord $entity, array $data): MatchRecord
    {
        throw new \LogicException('Not implemented');
    }

    public function recordResult(int $id, $p1Wins, $p2Wins): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('MatchRecord not found: ' . $id);
        $entity->recordResult($p1Wins, $p2Wins);
        $entity->determineWinner(); // @after
        $this->repository->save($entity, flush: true);
    }

    public function determineWinner(int $id): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('MatchRecord not found: ' . $id);
        $result = $entity->determineWinner();
        $this->repository->save($entity, flush: true);
        return $result;
    }

    public function draw(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('MatchRecord not found: ' . $id);
        $entity->draw();
        $this->repository->save($entity, flush: true);
    }
}
