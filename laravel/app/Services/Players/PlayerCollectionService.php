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
    public function estimatedValue(int $id): string
    {
        $playerCollection = PlayerCollection::findOrFail($id);
        $result = $playerCollection->estimatedValue();
        $playerCollection->save();
        return $result;
    }
}
