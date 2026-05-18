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
            'discount_value' => 'required',
            'min_order_value' => 'required',
            'max_uses' => 'nullable|integer',
            'uses_count' => 'required|integer',
            'valid_from' => 'required|date',
            'valid_until' => 'required|date',
            'is_active' => 'required|boolean',
        ]);
        $item = Coupon::create($validated);
        $item->validateRules();
        try {
            $item->validateImplies();
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }

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
            'discount_value' => 'sometimes|nullable',
            'min_order_value' => 'sometimes|nullable',
            'max_uses' => 'sometimes|nullable|integer',
            'uses_count' => 'sometimes|nullable|integer',
            'valid_from' => 'sometimes|nullable|date',
            'valid_until' => 'sometimes|nullable|date',
            'is_active' => 'sometimes|nullable|boolean',
        ]);
        $coupon->update($validated);
        $coupon->validateRules();
        try {
            $coupon->validateImplies();
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }

        return response()->json($coupon);
    }

    public function destroy(Coupon $coupon): JsonResponse
    {
        $coupon->delete();
        return response()->json(null, 204);
    }
    public function isValid(Request $request, Coupon $coupon): JsonResponse
    {
        $result = $coupon->isValid();
        $coupon->save();
        return response()->json(['result' => $result]);
    }

    public function isApplicableToOrder(Request $request, Coupon $coupon): JsonResponse
    {
        $result = $coupon->isApplicableToOrder();
        $coupon->save();
        return response()->json(['result' => $result]);
    }

    public function redeem(Request $request, Coupon $coupon): JsonResponse
    {
        $coupon->redeem();
        $coupon->save();
        return response()->json(null, 204);
    }

    public function deactivate(Request $request, Coupon $coupon): JsonResponse
    {
        $coupon->deactivate();
        $coupon->save();
        return response()->json(null, 204);
    }
}
