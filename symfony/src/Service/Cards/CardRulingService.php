<?php

namespace App\Service\Cards;

use App\Entity\Cards\CardRuling;
use App\Repository\Cards\CardRulingRepository;

class CardRulingService
{
    public function __construct(
        private CardRulingRepository $repository,
    ) {}

    public function create(array $data): CardRuling
    {
        throw new \LogicException('Not implemented');
    }

    public function update(CardRuling $entity, array $data): CardRuling
    {
        throw new \LogicException('Not implemented');
    }

    public function isCurrent(int $id): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('CardRuling not found: ' . $id);
        $result = $entity->isCurrent();
        $this->repository->save($entity, flush: true);
        return $result;
    }

    public function supersedesPrevious(int $id): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('CardRuling not found: ' . $id);
        $result = $entity->supersedesPrevious();
        $this->repository->save($entity, flush: true);
        return $result;
    }
}
