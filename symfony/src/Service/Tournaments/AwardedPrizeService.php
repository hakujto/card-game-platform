<?php

namespace App\Service\Tournaments;

use App\Entity\Tournaments\AwardedPrize;
use App\Repository\Tournaments\AwardedPrizeRepository;

class AwardedPrizeService
{
    public function __construct(
        private AwardedPrizeRepository $repository,
    ) {}

    public function create(array $data): AwardedPrize
    {
        throw new \LogicException('Not implemented');
    }

    public function update(AwardedPrize $entity, array $data): AwardedPrize
    {
        throw new \LogicException('Not implemented');
    }

    public function claim(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('AwardedPrize not found: ' . $id);
        $entity->claim();
        $this->repository->save($entity, flush: true);
    }

    public function setClaimed(int $id, string $value): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('AwardedPrize not found: ' . $id);
        $entity->setClaimed($value);
        if ($value === 'TRUE') {
            $entity->claim(); // @on(claimed = true)
        }
        $this->repository->save($entity, flush: true);
    }
}
