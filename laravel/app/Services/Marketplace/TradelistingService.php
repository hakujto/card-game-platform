<?php

namespace App\Services\Marketplace;

use App\Models\Marketplace\Tradelisting;

class TradelistingService
{
    public function create(array $data): Tradelisting
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Tradelisting $tradelisting, array $data): Tradelisting
    {
        throw new \LogicException('Not implemented');
    }
    public function close(int $id): void
    {
        $tradelisting = Tradelisting::findOrFail($id);
        $tradelisting->close();
        $tradelisting->save();
    }

    public function extend(int $id, $days): void
    {
        $tradelisting = Tradelisting::findOrFail($id);
        $tradelisting->extend($days);
        $tradelisting->save();
    }

    public function cancel(int $id): void
    {
        $tradelisting = Tradelisting::findOrFail($id);
        $tradelisting->cancel();
        $tradelisting->save();
    }

    // triggered by @on(status = Sold)
    public function setStatus(int $id, string $value): void
    {
        $tradelisting = Tradelisting::findOrFail($id);
        $tradelisting->status = $value;
        if ($value === 'Sold') {
            $tradelisting->finalizeAuction();
        }
        $tradelisting->save();
    }
}
