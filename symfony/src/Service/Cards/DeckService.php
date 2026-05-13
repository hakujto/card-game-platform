<?php

namespace App\Service\Cards;

use App\Entity\Cards\Deck;
use App\Repository\Cards\DeckRepository;

class DeckService
{
    public function __construct(
        private DeckRepository $repository,
    ) {}

    public function create(array $data): Deck
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Deck $entity, array $data): Deck
    {
        throw new \LogicException('Not implemented');
    }

    public function validateSize(int $id): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Deck not found: ' . $id);
        $result = $entity->validateSize();
        $this->repository->save($entity, flush: true);
        return $result;
    }

    public function clone(int $id): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Deck not found: ' . $id);
        $result = $entity->clone();
        $this->repository->save($entity, flush: true);
        return $result;
    }

    public function publish(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Deck not found: ' . $id);
        $entity->publish();
        $this->repository->save($entity, flush: true);
    }

    public function unpublish(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Deck not found: ' . $id);
        $entity->unpublish();
        $this->repository->save($entity, flush: true);
    }

    public function certifyTournamentLegal(int $id): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Deck not found: ' . $id);
        $result = $entity->certifyTournamentLegal();
        $this->repository->save($entity, flush: true);
        return $result;
    }
}
