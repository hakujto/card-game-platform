<?php

namespace App\Http\Controllers\Api\Marketplace;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Marketplace\TradeTransaction;
use App\Models\Marketplace\Tradelisting;
use App\Models\Players\Player;

class TradeTransactionController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(TradeTransaction::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'final_price' => 'required|max:200',
            'platform_fee' => 'required|max:200',
            'status' => 'required|string|in:Pending,Completed,Disputed,Refunded|max:20',
            'completed_at' => 'nullable|date|max:200',
            'listing_id' => 'required|exists:tradelistings,id',
            'buyer_id' => 'required|exists:players,id',
            'seller_id' => 'required|exists:players,id',
        ]);
        $item = TradeTransaction::create($validated);
        return response()->json($item, 201);
    }

    public function show(TradeTransaction $tradeTransaction): JsonResponse
    {
        return response()->json($tradeTransaction);
    }

    public function update(Request $request, TradeTransaction $tradeTransaction): JsonResponse
    {
        $validated = $request->validate([
            'final_price' => 'sometimes|nullable|max:200',
            'platform_fee' => 'sometimes|nullable|max:200',
            'status' => 'sometimes|nullable|string|max:20',
            'completed_at' => 'sometimes|nullable|date|max:200',
            'listing_id' => 'sometimes|nullable|exists:tradelistings,id',
            'buyer_id' => 'sometimes|nullable|exists:players,id',
            'seller_id' => 'sometimes|nullable|exists:players,id',
        ]);
        $tradeTransaction->update($validated);
        return response()->json($tradeTransaction);
    }

    public function destroy(TradeTransaction $tradeTransaction): JsonResponse
    {
        $tradeTransaction->delete();
        return response()->json(null, 204);
    }
}
