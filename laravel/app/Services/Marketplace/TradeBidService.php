<?php

namespace App\Services\Marketplace;

use App\Models\Marketplace\TradeBid;

class TradeBidService
{
    public function create(array $data): TradeBid
    {
        throw new \LogicException('Not implemented');
    }

    public function update(TradeBid $tradeBid, array $data): TradeBid
    {
        throw new \LogicException('Not implemented');
    }
    public function outbidBy(int $id): bool
    {
        $tradeBid = TradeBid::findOrFail($id);
        $result = $tradeBid->outbidBy($new_amount);
        $tradeBid->save();
        return $result;
    }

    public function retract(int $id): void
    {
        $tradeBid = TradeBid::findOrFail($id);
        $tradeBid->retract();
        $tradeBid->save();
    }
}
