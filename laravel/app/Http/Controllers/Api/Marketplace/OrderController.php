<?php

namespace App\Http\Controllers\Api\Marketplace;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Marketplace\Order;
use App\Models\Players\Player;
use App\Models\Marketplace\Coupon;

class OrderController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(Order::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'status' => 'required|string|in:Pending,Paid,Processing,Shipped,Completed,Cancelled,Refunded|max:20',
            'total' => 'required|max:200',
            'discount_applied' => 'required|max:200',
            'currency' => 'required|string|max:3',
            'payment_method' => 'nullable|string|in:Card,PayPal,Crypto,PlatformCredits|max:20',
            'payment_reference' => 'nullable|string|max:200',
            'shipping_address' => 'nullable|string|max:200',
            'tracking_number' => 'nullable|string|max:100',
            'created_at' => 'required|date|max:200',
            'paid_at' => 'nullable|date|max:200',
            'shipped_at' => 'nullable|date|max:200',
            'player_id' => 'required|exists:players,id',
            'coupon_id' => 'nullable|exists:coupons,id',
        ]);
        $item = Order::create($validated);
        return response()->json($item, 201);
    }

    public function show(Order $order): JsonResponse
    {
        return response()->json($order);
    }

    public function update(Request $request, Order $order): JsonResponse
    {
        $validated = $request->validate([
            'status' => 'sometimes|nullable|string|max:20',
            'total' => 'sometimes|nullable|max:200',
            'discount_applied' => 'sometimes|nullable|max:200',
            'currency' => 'sometimes|nullable|string|max:3',
            'payment_method' => 'sometimes|nullable|string|max:20',
            'payment_reference' => 'sometimes|nullable|string|max:200',
            'shipping_address' => 'sometimes|nullable|string|max:200',
            'tracking_number' => 'sometimes|nullable|string|max:100',
            'created_at' => 'sometimes|nullable|date|max:200',
            'paid_at' => 'sometimes|nullable|date|max:200',
            'shipped_at' => 'sometimes|nullable|date|max:200',
            'player_id' => 'sometimes|nullable|exists:players,id',
            'coupon_id' => 'sometimes|nullable|exists:coupons,id',
        ]);
        $order->update($validated);
        return response()->json($order);
    }

    public function destroy(Order $order): JsonResponse
    {
        $order->delete();
        return response()->json(null, 204);
    }
}
