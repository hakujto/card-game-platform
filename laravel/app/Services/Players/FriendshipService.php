<?php

namespace App\Services\Players;

use App\Models\Players\Friendship;

class FriendshipService
{
    public function create(array $data): Friendship
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Friendship $friendship, array $data): Friendship
    {
        throw new \LogicException('Not implemented');
    }
    public function accept(int $id): void
    {
        $friendship = Friendship::findOrFail($id);
        $friendship->accept();
        $friendship->save();
    }

    public function decline(int $id): void
    {
        $friendship = Friendship::findOrFail($id);
        $friendship->decline();
        $friendship->save();
    }

    public function block(int $id): void
    {
        $friendship = Friendship::findOrFail($id);
        $friendship->block();
        $friendship->save();
    }
}
