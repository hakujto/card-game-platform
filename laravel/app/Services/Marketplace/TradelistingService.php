<?php

namespace App\Services\Marketplace;

use App\Models\Marketplace\TradeListing;

class TradeListingService
{
    public function create(array $data): TradeListing
    {
        throw new \LogicException('Not implemented');
    }

    public function update(TradeListing $tradeListing, array $data): TradeListing
    {
        throw new \LogicException('Not implemented');
    }
    public function close(int $id): void
    {
        $tradeListing = TradeListing::findOrFail($id);
        $tradeListing->close();
        $tradeListing->save();
    }

    public function extend(int $id, $days): void
    {
        $tradeListing = TradeListing::findOrFail($id);
        $tradeListing->extend($days);
        $tradeListing->save();
    }

    public function cancel(int $id): void
    {
        $tradeListing = TradeListing::findOrFail($id);
        $tradeListing->cancel();
        $tradeListing->save();
    }

    public function isExpired(int $id): bool
    {
        $tradeListing = TradeListing::findOrFail($id);
        $result = $tradeListing->isExpired();
        $tradeListing->save();
        return $result;
    }

    public function finalizeAuction(int $id): void
    {
        $tradeListing = TradeListing::findOrFail($id);
        $tradeListing->finalizeAuction();
        $tradeListing->save();
    }

    // triggered by @on(status = Sold)
    public function setStatus(int $id, string $value): void
    {
        $tradeListing = TradeListing::findOrFail($id);
        $tradeListing->status = $value;
        if ($value === 'Sold') {
            $tradeListing->finalizeAuction();
        }
        $tradeListing->save();
    }
}
