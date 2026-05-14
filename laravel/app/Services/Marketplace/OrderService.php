<?php

namespace App\Services\Marketplace;

use App\Models\Marketplace\Order;

class OrderService
{
    public function create(array $data): Order
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Order $order, array $data): Order
    {
        throw new \LogicException('Not implemented');
    }
    public function cancel(int $id): void
    {
        $order = Order::findOrFail($id);
        $order->cancel();
        $order->save();
    }

    public function pay(int $id, $payment_ref): bool
    {
        $order = Order::findOrFail($id);
        $result = $order->pay($payment_ref);
        $order->save();
        return $result;
    }

    public function calculateTotal(int $id): string
    {
        $order = Order::findOrFail($id);
        $result = $order->calculateTotal();
        $order->save();
        return $result;
    }

    public function applyDiscount(int $id, $percent): string
    {
        $order = Order::findOrFail($id);
        $result = $order->applyDiscount($percent);
        $order->save();
        return $result;
    }

    public function refund(int $id): void
    {
        $order = Order::findOrFail($id);
        $order->refund();
        $order->save();
    }

    // triggered by @on(status = Shipped)
    public function setStatus(int $id, string $value): void
    {
        $order = Order::findOrFail($id);
        $order->status = $value;
        if ($value === 'Shipped') {
            $order->notifyShipped();
        }
        $order->save();
    }
}
