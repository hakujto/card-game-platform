<?php

namespace App\Http\Controllers\Api\Marketplace;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Marketplace\Coupon;

class CouponController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(Coupon::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'code' => 'required|string|max:50',
            'discount_type' => 'required|string|in:Percent,Fixed|max:20',
            'discount_value' => 'required|max:200',
            'min_order_value' => 'required|max:200',
            'max_uses' => 'nullable|integer|max:200',
            'uses_count' => 'required|integer|max:200',
            'valid_from' => 'required|date|max:200',
            'valid_until' => 'required|date|max:200',
            'is_active' => 'required|boolean|max:200',
        ]);
        $item = Coupon::create($validated);
        return response()->json($item, 201);
    }

    public function show(Coupon $coupon): JsonResponse
    {
        return response()->json($coupon);
    }

    public function update(Request $request, Coupon $coupon): JsonResponse
    {
        $validated = $request->validate([
            'code' => 'sometimes|nullable|string|max:50',
            'discount_type' => 'sometimes|nullable|string|max:20',
            'discount_value' => 'sometimes|nullable|max:200',
            'min_order_value' => 'sometimes|nullable|max:200',
            'max_uses' => 'sometimes|nullable|integer|max:200',
            'uses_count' => 'sometimes|nullable|integer|max:200',
            'valid_from' => 'sometimes|nullable|date|max:200',
            'valid_until' => 'sometimes|nullable|date|max:200',
            'is_active' => 'sometimes|nullable|boolean|max:200',
        ]);
        $coupon->update($validated);
        return response()->json($coupon);
    }

    public function destroy(Coupon $coupon): JsonResponse
    {
        $coupon->delete();
        return response()->json(null, 204);
    }
}
