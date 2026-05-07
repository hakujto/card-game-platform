<?php

namespace App\Service\Players;

use App\Entity\Players\Player;
use App\Repository\Players\PlayerRepository;

class PlayerService
{
    public function __construct(
        private PlayerRepository $repository,
    ) {}

    public function create(array $data): Player
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Player $entity, array $data): Player
    {
        throw new \LogicException('Not implemented');
    }
}
