<?php

namespace App\Services\Marketplace;

use App\Models\Marketplace\Coupon;

class CouponService
{
    public function create(array $data): Coupon
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Coupon $coupon, array $data): Coupon
    {
        throw new \LogicException('Not implemented');
    }
    public function isValid(int $id): bool
    {
        $coupon = Coupon::findOrFail($id);
        $result = $coupon->isValid();
        $coupon->save();
        return $result;
    }

    public function isApplicableToOrder(int $id): bool
    {
        $coupon = Coupon::findOrFail($id);
        $result = $coupon->isApplicableToOrder($order_total);
        $coupon->save();
        return $result;
    }

    public function redeem(int $id): void
    {
        $coupon = Coupon::findOrFail($id);
        $coupon->redeem();
        $coupon->save();
    }

    public function deactivate(int $id): void
    {
        $coupon = Coupon::findOrFail($id);
        $coupon->deactivate();
        $coupon->save();
    }
}
