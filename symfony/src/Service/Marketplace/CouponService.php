<?php

namespace App\Service\Marketplace;

use App\Entity\Marketplace\Coupon;
use App\Repository\Marketplace\CouponRepository;

class CouponService
{
    public function __construct(
        private CouponRepository $repository,
    ) {}

    public function create(array $data): Coupon
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Coupon $entity, array $data): Coupon
    {
        throw new \LogicException('Not implemented');
    }

    public function isValid(int $id): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Coupon not found: ' . $id);
        $result = $entity->isValid();
        $this->repository->save($entity, flush: true);
        return $result;
    }

    public function isApplicableToOrder(int $id, $orderTotal): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Coupon not found: ' . $id);
        $result = $entity->isApplicableToOrder($orderTotal);
        $this->repository->save($entity, flush: true);
        return $result;
    }

    public function redeem(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Coupon not found: ' . $id);
        $entity->redeem();
        $this->repository->save($entity, flush: true);
    }

    public function deactivate(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Coupon not found: ' . $id);
        $entity->deactivate();
        $this->repository->save($entity, flush: true);
    }
}
