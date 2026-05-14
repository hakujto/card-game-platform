<?php

namespace App\Services\Marketplace;

use App\Models\Marketplace\TradeTransaction;

class TradeTransactionService
{
    public function create(array $data): TradeTransaction
    {
        throw new \LogicException('Not implemented');
    }

    public function update(TradeTransaction $tradeTransaction, array $data): TradeTransaction
    {
        throw new \LogicException('Not implemented');
    }
    public function complete(int $id): void
    {
        $tradeTransaction = TradeTransaction::findOrFail($id);
        $tradeTransaction->complete();
        $tradeTransaction->save();
    }

    public function refund(int $id): void
    {
        $tradeTransaction = TradeTransaction::findOrFail($id);
        $tradeTransaction->refund();
        $tradeTransaction->save();
    }

    public function openDispute(int $id, $reason): void
    {
        $tradeTransaction = TradeTransaction::findOrFail($id);
        $tradeTransaction->openDispute($reason);
        $tradeTransaction->save();
    }
}
