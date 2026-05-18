<?php

namespace App\Service\Cards;

use App\Entity\Cards\DeckCard;
use App\Repository\Cards\DeckCardRepository;

class DeckCardService
{
    public function __construct(
        private DeckCardRepository $repository,
    ) {}

    public function create(array $data): DeckCard
    {
        throw new \LogicException('Not implemented');
    }

    public function update(DeckCard $entity, array $data): DeckCard
    {
        throw new \LogicException('Not implemented');
    }

    public function increment(int $id, $amount): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('DeckCard not found: ' . $id);
        $entity->increment($amount);
        $this->repository->save($entity, flush: true);
    }

    public function decrement(int $id, $amount): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('DeckCard not found: ' . $id);
        $entity->decrement($amount);
        $this->repository->save($entity, flush: true);
    }
}
