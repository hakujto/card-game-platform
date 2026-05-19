<?php

namespace App\Service\Marketplace;

use App\Entity\Marketplace\TradeListing;
use App\Repository\Marketplace\TradeListingRepository;
use Symfony\Component\HttpKernel\Exception\ConflictHttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\HttpKernel\Exception\UnprocessableEntityHttpException;

class TradeListingService
{
    public function __construct(
        private TradeListingRepository $repository,
    ) {}

    public function create(array $data): TradeListing
    {
        throw new \LogicException('Not implemented');
    }

    public function update(TradeListing $entity, array $data): TradeListing
    {
        throw new \LogicException('Not implemented');
    }

    public function close(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('TradeListing not found: ' . $id);
        $entity->close();
        $this->repository->save($entity, flush: true);
    }

    public function extend(int $id, $days): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('TradeListing not found: ' . $id);
        $entity->extend($days);
        $this->repository->save($entity, flush: true);
    }

    public function cancel(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('TradeListing not found: ' . $id);
        $entity->cancel();
        $this->repository->save($entity, flush: true);
    }

    public function isExpired(int $id): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('TradeListing not found: ' . $id);
        $result = $entity->isExpired();
        $this->repository->save($entity, flush: true);
        return $result;
    }

    public function finalizeAuction(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('TradeListing not found: ' . $id);
        $entity->finalizeAuction();
        $this->repository->save($entity, flush: true);
    }

    public function setStatus(int $id, string $value): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('TradeListing not found: ' . $id);
        $entity->setStatus($value);
        if ($value === 'SOLD') {
            $entity->finalizeAuction(); // @on(status = Sold)
        }
        $this->repository->save($entity, flush: true);
    }
    #[\Symfony\Component\Security\Http\Attribute\IsGranted('ROLE_SELLER')]
    public function transitionPendingToActive(int $id): object
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \Symfony\Component\HttpKernel\Exception\NotFoundHttpException();

        $entity->assertTransition($entity->getStatus(), 'Active');
        if ($entity->getQuantity() === null) {
            throw new \Symfony\Component\HttpKernel\Exception\UnprocessableEntityHttpException('quantity is required for Pending -> Active');
        }

        $entity->setStatus('Active');

        $this->repository->save($entity, flush: true);
        return $entity;
    }

    public function transitionActiveToSold(int $id): object
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \Symfony\Component\HttpKernel\Exception\NotFoundHttpException();

        $entity->assertTransition($entity->getStatus(), 'Sold');

        $entity->setStatus('Sold');
        $entity->finalizeAuction(); // @after

        $this->repository->save($entity, flush: true);
        return $entity;
    }

    public function transitionActiveToExpired(int $id): object
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \Symfony\Component\HttpKernel\Exception\NotFoundHttpException();

        $entity->assertTransition($entity->getStatus(), 'Expired');

        $entity->setStatus('Expired');
        $entity->close(); // @after

        $this->repository->save($entity, flush: true);
        return $entity;
    }

    #[\Symfony\Component\Security\Http\Attribute\IsGranted(['ROLE_SELLER'])]
    public function transitionActiveToCancelled(int $id): object
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \Symfony\Component\HttpKernel\Exception\NotFoundHttpException();

        $entity->assertTransition($entity->getStatus(), 'Cancelled');

        $entity->setStatus('Cancelled');
        $entity->cancel(); // @after

        $this->repository->save($entity, flush: true);
        return $entity;
    }

    public function transitionSoldToActive(int $id): never
    {
        throw new \Symfony\Component\HttpKernel\Exception\ConflictHttpException('Transition Sold -> Active is not allowed');
    }

    public function transitionExpiredToActive(int $id): never
    {
        throw new \Symfony\Component\HttpKernel\Exception\ConflictHttpException('Transition Expired -> Active is not allowed');
    }
}
