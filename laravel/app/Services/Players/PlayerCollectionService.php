<?php

namespace App\Services\Players;

use App\Models\Players\PlayerCollection;

class PlayerCollectionService
{
    public function create(array $data): PlayerCollection
    {
        throw new \LogicException('Not implemented');
    }

    public function update(PlayerCollection $playerCollection, array $data): PlayerCollection
    {
        throw new \LogicException('Not implemented');
    }
    public function add(int $id, $quantity): void
    {
        $playerCollection = PlayerCollection::findOrFail($id);
        $playerCollection->add($quantity);
        $playerCollection->save();
    }

    public function remove(int $id, $quantity): void
    {
        $playerCollection = PlayerCollection::findOrFail($id);
        $playerCollection->remove($quantity);
        $playerCollection->save();
    }

    public function estimatedValue(int $id): string
    {
        $playerCollection = PlayerCollection::findOrFail($id);
        $result = $playerCollection->estimatedValue();
        $playerCollection->save();
        return $result;
    }
}
