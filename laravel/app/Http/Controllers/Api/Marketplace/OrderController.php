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
            'total' => 'required',
            'discount_applied' => 'required',
            'currency' => 'required|string|max:3',
            'payment_method' => 'nullable|string|in:Card,PayPal,Crypto,PlatformCredits|max:20',
            'payment_reference' => 'nullable|string|max:200',
            'shipping_address' => 'nullable|string|max:200',
            'tracking_number' => 'nullable|string|max:100',
            'created_at' => 'required|date',
            'paid_at' => 'nullable|date',
            'shipped_at' => 'nullable|date',
            'player_id' => 'required|exists:players,id',
            'coupon_id' => 'nullable|exists:coupons,id',
        ]);
        $item = Order::create($validated);
        $item->validateRules();
        try {
            $item->validateImplies();
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }

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
            'total' => 'sometimes|nullable',
            'discount_applied' => 'sometimes|nullable',
            'currency' => 'sometimes|nullable|string|max:3',
            'payment_method' => 'sometimes|nullable|string|max:20',
            'payment_reference' => 'sometimes|nullable|string|max:200',
            'shipping_address' => 'sometimes|nullable|string|max:200',
            'tracking_number' => 'sometimes|nullable|string|max:100',
            'created_at' => 'sometimes|nullable|date',
            'paid_at' => 'sometimes|nullable|date',
            'shipped_at' => 'sometimes|nullable|date',
            'player_id' => 'sometimes|nullable|exists:players,id',
            'coupon_id' => 'sometimes|nullable|exists:coupons,id',
        ]);
        $order->update($validated);
        $order->validateRules();
        try {
            $order->validateImplies();
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }

        return response()->json($order);
    }

    public function destroy(Order $order): JsonResponse
    {
        $order->delete();
        return response()->json(null, 204);
    }
    public function cancel(Request $request, Order $order): JsonResponse
    {
        $order->cancel();
        $order->save();
        return response()->json(null, 204);
    }

    public function pay(Request $request, Order $order): JsonResponse
    {
        $payment_ref = $request->input('payment_ref');
        $result = $order->pay($payment_ref);
        $order->save();
        return response()->json(['result' => $result]);
    }

    public function calculateTotal(Request $request, Order $order): JsonResponse
    {
        $result = $order->calculateTotal();
        $order->save();
        return response()->json(['result' => $result]);
    }

    public function applyDiscount(Request $request, Order $order): JsonResponse
    {
        $percent = $request->input('percent');
        $result = $order->applyDiscount($percent);
        $order->save();
        return response()->json(['result' => $result]);
    }

    public function refund(Request $request, Order $order): JsonResponse
    {
        $order->refund();
        $order->save();
        return response()->json(null, 204);
    }
}
