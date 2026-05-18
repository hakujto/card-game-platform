<?php

namespace App\Service\Cards;

use App\Entity\Cards\CardSet;
use App\Repository\Cards\CardSetRepository;

class CardSetService
{
    public function __construct(
        private CardSetRepository $repository,
    ) {}

    public function create(array $data): CardSet
    {
        throw new \LogicException('Not implemented');
    }

    public function update(CardSet $entity, array $data): CardSet
    {
        throw new \LogicException('Not implemented');
    }

    public function isLegalInStandard(int $id): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('CardSet not found: ' . $id);
        $result = $entity->isLegalInStandard();
        $this->repository->save($entity, flush: true);
        return $result;
    }

    public function isLegalInFormat(int $id, $format): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('CardSet not found: ' . $id);
        $result = $entity->isLegalInFormat($format);
        $this->repository->save($entity, flush: true);
        return $result;
    }

    public function cardCountByRarity(int $id, $rarity): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('CardSet not found: ' . $id);
        $result = $entity->cardCountByRarity($rarity);
        $this->repository->save($entity, flush: true);
        return $result;
    }

    public function rotateOut(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('CardSet not found: ' . $id);
        $entity->rotateOut();
        $this->repository->save($entity, flush: true);
    }
}
