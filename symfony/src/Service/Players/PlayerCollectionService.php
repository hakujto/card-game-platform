<?php

namespace App\Service\Players;

use App\Entity\Players\PlayerCollection;
use App\Repository\Players\PlayerCollectionRepository;

class PlayerCollectionService
{
    public function __construct(
        private PlayerCollectionRepository $repository,
    ) {}

    public function create(array $data): PlayerCollection
    {
        throw new \LogicException('Not implemented');
    }

    public function update(PlayerCollection $entity, array $data): PlayerCollection
    {
        throw new \LogicException('Not implemented');
    }
}
