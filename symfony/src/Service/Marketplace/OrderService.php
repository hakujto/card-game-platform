<?php

namespace App\Service\Marketplace;

use App\Entity\Marketplace\Order;
use App\Repository\Marketplace\OrderRepository;

class OrderService
{
    public function __construct(
        private OrderRepository $repository,
    ) {}

    public function create(array $data): Order
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Order $entity, array $data): Order
    {
        throw new \LogicException('Not implemented');
    }

    public function cancel(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Order not found: ' . $id);
        $entity->cancel();
        $this->repository->save($entity, flush: true);
    }

    public function pay(int $id, $paymentRef): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Order not found: ' . $id);
        $result = $entity->pay($paymentRef);
        $this->repository->save($entity, flush: true);
        return $result;
    }

    public function calculateTotal(int $id): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Order not found: ' . $id);
        $result = $entity->calculateTotal();
        $this->repository->save($entity, flush: true);
        return $result;
    }

    public function applyDiscount(int $id, $percent): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Order not found: ' . $id);
        $result = $entity->applyDiscount($percent);
        $this->repository->save($entity, flush: true);
        return $result;
    }

    public function refund(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Order not found: ' . $id);
        $entity->refund();
        $this->repository->save($entity, flush: true);
    }

    public function setStatus(int $id, string $value): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Order not found: ' . $id);
        $entity->setStatus($value);
        if ($value === 'SHIPPED') {
            $entity->notifyShipped(); // @on(status = Shipped)
        }
        $this->repository->save($entity, flush: true);
    }
}
