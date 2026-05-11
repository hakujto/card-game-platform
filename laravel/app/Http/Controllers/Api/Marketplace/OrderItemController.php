<?php

namespace App\Http\Controllers\Api\Marketplace;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Marketplace\OrderItem;
use App\Models\Marketplace\Order;
use App\Models\Marketplace\Product;

class OrderItemController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(OrderItem::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'quantity' => 'required|integer|max:200',
            'price_at_purchase' => 'required|max:200',
            'foil' => 'required|boolean|max:200',
            'order_id' => 'required|exists:orders,id',
            'product_id' => 'required|exists:products,id',
        ]);
        $item = OrderItem::create($validated);
        return response()->json($item, 201);
    }

    public function show(OrderItem $orderItem): JsonResponse
    {
        return response()->json($orderItem);
    }

    public function update(Request $request, OrderItem $orderItem): JsonResponse
    {
        $validated = $request->validate([
            'quantity' => 'sometimes|nullable|integer|max:200',
            'price_at_purchase' => 'sometimes|nullable|max:200',
            'foil' => 'sometimes|nullable|boolean|max:200',
            'order_id' => 'sometimes|nullable|exists:orders,id',
            'product_id' => 'sometimes|nullable|exists:products,id',
        ]);
        $orderItem->update($validated);
        return response()->json($orderItem);
    }

    public function destroy(OrderItem $orderItem): JsonResponse
    {
        $orderItem->delete();
        return response()->json(null, 204);
    }
}
