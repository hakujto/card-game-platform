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
}
