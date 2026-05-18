<?php

namespace App\Service\Cards;

use App\Entity\Cards\Card;
use App\Repository\Cards\CardRepository;

class CardService
{
    public function __construct(
        private CardRepository $repository,
    ) {}

    public function create(array $data): Card
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Card $entity, array $data): Card
    {
        throw new \LogicException('Not implemented');
    }

    public function ban(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Card not found: ' . $id);
        $entity->ban();
        $this->repository->save($entity, flush: true);
    }

    public function unban(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Card not found: ' . $id);
        $entity->unban();
        $this->repository->save($entity, flush: true);
    }

    public function restrict(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Card not found: ' . $id);
        $entity->restrict();
        $this->repository->save($entity, flush: true);
    }

    public function unrestrict(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Card not found: ' . $id);
        $entity->unrestrict();
        $this->repository->save($entity, flush: true);
    }

    public function calculateValue(int $id): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Card not found: ' . $id);
        $result = $entity->calculateValue();
        $this->repository->save($entity, flush: true);
        return $result;
    }

    public function applyRarityBonus(int $id, $multiplier): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Card not found: ' . $id);
        $result = $entity->applyRarityBonus($multiplier);
        $this->repository->save($entity, flush: true);
        return $result;
    }

    public function isLegalInFormat(int $id, $format): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Card not found: ' . $id);
        $result = $entity->isLegalInFormat($format);
        $this->repository->save($entity, flush: true);
        return $result;
    }
}
