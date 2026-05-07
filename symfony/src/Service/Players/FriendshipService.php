<?php

namespace App\Service\Players;

use App\Entity\Players\Friendship;
use App\Repository\Players\FriendshipRepository;

class FriendshipService
{
    public function __construct(
        private FriendshipRepository $repository,
    ) {}

    public function create(array $data): Friendship
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Friendship $entity, array $data): Friendship
    {
        throw new \LogicException('Not implemented');
    }
}
