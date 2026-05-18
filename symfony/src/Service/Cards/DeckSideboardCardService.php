<?php

namespace App\Service\Cards;

use App\Entity\Cards\DeckSideboardCard;
use App\Repository\Cards\DeckSideboardCardRepository;

class DeckSideboardCardService
{
    public function __construct(
        private DeckSideboardCardRepository $repository,
    ) {}

    public function create(array $data): DeckSideboardCard
    {
        throw new \LogicException('Not implemented');
    }

    public function update(DeckSideboardCard $entity, array $data): DeckSideboardCard
    {
        throw new \LogicException('Not implemented');
    }

    public function increment(int $id, $amount): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('DeckSideboardCard not found: ' . $id);
        $entity->increment($amount);
        $this->repository->save($entity, flush: true);
    }

    public function decrement(int $id, $amount): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('DeckSideboardCard not found: ' . $id);
        $entity->decrement($amount);
        $this->repository->save($entity, flush: true);
    }
}
