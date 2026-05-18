<?php

namespace App\Services\Marketplace;

use App\Models\Marketplace\CardPriceHistory;

class CardPriceHistoryService
{
    public function create(array $data): CardPriceHistory
    {
        throw new \LogicException('Not implemented');
    }

    public function update(CardPriceHistory $cardPriceHistory, array $data): CardPriceHistory
    {
        throw new \LogicException('Not implemented');
    }
    public function priceChangePercent(int $id): string
    {
        $cardPriceHistory = CardPriceHistory::findOrFail($id);
        $result = $cardPriceHistory->priceChangePercent($previous_avg);
        $cardPriceHistory->save();
        return $result;
    }

    public function isPriceSpike(int $id): bool
    {
        $cardPriceHistory = CardPriceHistory::findOrFail($id);
        $result = $cardPriceHistory->isPriceSpike($threshold_percent);
        $cardPriceHistory->save();
        return $result;
    }
}
