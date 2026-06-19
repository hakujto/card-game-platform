<?php

namespace App\Service\Marketplace;

use App\Entity\Marketplace\Order;
use App\Repository\Marketplace\OrderRepository;
use Symfony\Component\HttpKernel\Exception\ConflictHttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\HttpKernel\Exception\UnprocessableEntityHttpException;

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
        if (!($entity->getStatus() === 'Pending'))
            throw new \RuntimeException('Guard condition not met for pay');
        $result = $entity->pay($paymentRef);
        $this->repository->save($entity, flush: true);
        return $result;
    }

    public function processPayment(int $id): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Order not found: ' . $id);
        $result = $entity->processPayment();
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
    public function transitionPendingToPaid(int $id): object
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \Symfony\Component\HttpKernel\Exception\NotFoundHttpException();

        $entity->assertTransition($entity->getStatus(), 'Paid');
        if ($entity->getPaymentMethod() === null) {
            throw new \Symfony\Component\HttpKernel\Exception\UnprocessableEntityHttpException('payment_method is required for Pending -> Paid');
        }

        $entity->setStatus('Paid');
        $entity->processPayment(); // @after

        $this->repository->save($entity, flush: true);
        return $entity;
    }

    public function transitionPaidToProcessing(int $id): object
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \Symfony\Component\HttpKernel\Exception\NotFoundHttpException();

        $entity->assertTransition($entity->getStatus(), 'Processing');

        $entity->setStatus('Processing');

        $this->repository->save($entity, flush: true);
        return $entity;
    }

    public function transitionProcessingToShipped(int $id): object
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \Symfony\Component\HttpKernel\Exception\NotFoundHttpException();

        $entity->assertTransition($entity->getStatus(), 'Shipped');
        if ($entity->getTrackingNumber() === null) {
            throw new \Symfony\Component\HttpKernel\Exception\UnprocessableEntityHttpException('tracking_number is required for Processing -> Shipped');
        }

        $entity->setStatus('Shipped');
        $entity->notifyShipped(); // @after

        $this->repository->save($entity, flush: true);
        return $entity;
    }

    public function transitionShippedToCompleted(int $id): object
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \Symfony\Component\HttpKernel\Exception\NotFoundHttpException();

        $entity->assertTransition($entity->getStatus(), 'Completed');

        $entity->setStatus('Completed');

        $this->repository->save($entity, flush: true);
        return $entity;
    }

    public function transitionPendingToCancelled(int $id): object
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \Symfony\Component\HttpKernel\Exception\NotFoundHttpException();

        $entity->assertTransition($entity->getStatus(), 'Cancelled');

        $entity->setStatus('Cancelled');
        $entity->cancel(); // @after

        $this->repository->save($entity, flush: true);
        return $entity;
    }

    public function transitionPaidToCancelled(int $id): object
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \Symfony\Component\HttpKernel\Exception\NotFoundHttpException();

        $entity->assertTransition($entity->getStatus(), 'Cancelled');

        $entity->setStatus('Cancelled');
        $entity->cancel(); // @after

        $this->repository->save($entity, flush: true);
        return $entity;
    }

    public function transitionCompletedToRefunded(int $id): object
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \Symfony\Component\HttpKernel\Exception\NotFoundHttpException();

        $entity->assertTransition($entity->getStatus(), 'Refunded');

        $entity->setStatus('Refunded');
        $entity->refund(); // @after

        $this->repository->save($entity, flush: true);
        return $entity;
    }

    public function transitionRefundedToCompleted(int $id): never
    {
        throw new \Symfony\Component\HttpKernel\Exception\ConflictHttpException('Transition Refunded -> Completed is not allowed');
    }

    public function transitionCompletedToCancelled(int $id): never
    {
        throw new \Symfony\Component\HttpKernel\Exception\ConflictHttpException('Transition Completed -> Cancelled is not allowed');
    }
}
