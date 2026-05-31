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

    public function processPayment(Request $request, Order $order): JsonResponse
    {
        $result = $order->processPayment();
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
    public function transitionPendingToPaid(Order $order): JsonResponse
    {
        try {
            $order->assertTransition('Paid');
        } catch (\InvalidArgumentException $e) {
            return response()->json(['error' => $e->getMessage()], 409);
        }
        try {
            if ($order->payment_method === null) {
                throw new \RuntimeException('payment_method is required for Pending -> Paid');
            }
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }
        $order->status = 'Paid';
        $order->processPayment(); // @after
        $order->save();
        return response()->json($order);
    }

    public function transitionPaidToProcessing(Order $order): JsonResponse
    {
        try {
            $order->assertTransition('Processing');
        } catch (\InvalidArgumentException $e) {
            return response()->json(['error' => $e->getMessage()], 409);
        }
        $order->status = 'Processing';
        $order->save();
        return response()->json($order);
    }

    public function transitionProcessingToShipped(Order $order): JsonResponse
    {
        try {
            $order->assertTransition('Shipped');
        } catch (\InvalidArgumentException $e) {
            return response()->json(['error' => $e->getMessage()], 409);
        }
        try {
            if ($order->tracking_number === null) {
                throw new \RuntimeException('tracking_number is required for Processing -> Shipped');
            }
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }
        $order->status = 'Shipped';
        $order->notifyShipped(); // @after
        $order->save();
        return response()->json($order);
    }

    public function transitionShippedToCompleted(Order $order): JsonResponse
    {
        try {
            $order->assertTransition('Completed');
        } catch (\InvalidArgumentException $e) {
            return response()->json(['error' => $e->getMessage()], 409);
        }
        $order->status = 'Completed';
        $order->save();
        return response()->json($order);
    }

    public function transitionPendingToCancelled(Order $order): JsonResponse
    {
        try {
            $order->assertTransition('Cancelled');
        } catch (\InvalidArgumentException $e) {
            return response()->json(['error' => $e->getMessage()], 409);
        }
        $order->status = 'Cancelled';
        $order->cancel(); // @after
        $order->save();
        return response()->json($order);
    }

    public function transitionPaidToCancelled(Order $order): JsonResponse
    {
        try {
            $order->assertTransition('Cancelled');
        } catch (\InvalidArgumentException $e) {
            return response()->json(['error' => $e->getMessage()], 409);
        }
        $order->status = 'Cancelled';
        $order->cancel(); // @after
        $order->save();
        return response()->json($order);
    }

    public function transitionCompletedToRefunded(Order $order): JsonResponse
    {
        try {
            $order->assertTransition('Refunded');
        } catch (\InvalidArgumentException $e) {
            return response()->json(['error' => $e->getMessage()], 409);
        }
        $order->status = 'Refunded';
        $order->refund(); // @after
        $order->save();
        return response()->json($order);
    }

    public function transitionRefundedToCompleted(Order $order): JsonResponse
    {
        return response()->json(['error' => 'Transition Refunded -> Completed is not allowed'], 409);
    }

    public function transitionCompletedToCancelled(Order $order): JsonResponse
    {
        return response()->json(['error' => 'Transition Completed -> Cancelled is not allowed'], 409);
    }
}
