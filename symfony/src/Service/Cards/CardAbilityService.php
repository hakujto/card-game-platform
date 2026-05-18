<?php

namespace App\Service\Cards;

use App\Entity\Cards\CardAbility;
use App\Repository\Cards\CardAbilityRepository;

class CardAbilityService
{
    public function __construct(
        private CardAbilityRepository $repository,
    ) {}

    public function create(array $data): CardAbility
    {
        throw new \LogicException('Not implemented');
    }

    public function update(CardAbility $entity, array $data): CardAbility
    {
        throw new \LogicException('Not implemented');
    }

    public function isUsableAt(int $id, $timing): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('CardAbility not found: ' . $id);
        $result = $entity->isUsableAt($timing);
        $this->repository->save($entity, flush: true);
        return $result;
    }

    public function describe(int $id): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('CardAbility not found: ' . $id);
        $result = $entity->describe();
        $this->repository->save($entity, flush: true);
        return $result;
    }
}
