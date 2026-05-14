<?php

namespace App\Services\Marketplace;

use App\Models\Marketplace\TradeDispute;

class TradeDisputeService
{
    public function create(array $data): TradeDispute
    {
        throw new \LogicException('Not implemented');
    }

    public function update(TradeDispute $tradeDispute, array $data): TradeDispute
    {
        throw new \LogicException('Not implemented');
    }
    public function escalate(int $id): void
    {
        $tradeDispute = TradeDispute::findOrFail($id);
        $tradeDispute->escalate();
        $tradeDispute->save();
    }

    public function resolve(int $id, $resolution_text): void
    {
        $tradeDispute = TradeDispute::findOrFail($id);
        $tradeDispute->resolve($resolution_text);
        $tradeDispute->save();
    }

    public function review(int $id): void
    {
        $tradeDispute = TradeDispute::findOrFail($id);
        $tradeDispute->review();
        $tradeDispute->save();
    }
}
