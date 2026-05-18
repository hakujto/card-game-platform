<?php

namespace App\Http\Controllers\Api\Marketplace;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Marketplace\TradeTransaction;
use App\Models\Marketplace\TradeListing;
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
            'final_price' => 'required',
            'platform_fee' => 'required',
            'status' => 'required|string|in:Pending,Completed,Disputed,Refunded|max:20',
            'completed_at' => 'nullable|date',
            'listing_id' => 'required|exists:trade_listings,id',
            'buyer_id' => 'required|exists:players,id',
            'seller_id' => 'required|exists:players,id',
        ]);
        $item = TradeTransaction::create($validated);
        $item->validateRules();
        try {
            $item->validateImplies();
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }

        return response()->json($item, 201);
    }

    public function show(TradeTransaction $tradeTransaction): JsonResponse
    {
        return response()->json($tradeTransaction);
    }

    public function update(Request $request, TradeTransaction $tradeTransaction): JsonResponse
    {
        $validated = $request->validate([
            'final_price' => 'sometimes|nullable',
            'platform_fee' => 'sometimes|nullable',
            'status' => 'sometimes|nullable|string|max:20',
            'completed_at' => 'sometimes|nullable|date',
            'listing_id' => 'sometimes|nullable|exists:trade_listings,id',
            'buyer_id' => 'sometimes|nullable|exists:players,id',
            'seller_id' => 'sometimes|nullable|exists:players,id',
        ]);
        $tradeTransaction->update($validated);
        $tradeTransaction->validateRules();
        try {
            $tradeTransaction->validateImplies();
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }

        return response()->json($tradeTransaction);
    }

    public function destroy(TradeTransaction $tradeTransaction): JsonResponse
    {
        $tradeTransaction->delete();
        return response()->json(null, 204);
    }
    public function complete(Request $request, TradeTransaction $tradeTransaction): JsonResponse
    {
        $tradeTransaction->complete();
        $tradeTransaction->save();
        return response()->json(null, 204);
    }

    public function refund(Request $request, TradeTransaction $tradeTransaction): JsonResponse
    {
        $tradeTransaction->refund();
        $tradeTransaction->save();
        return response()->json(null, 204);
    }

    public function openDispute(Request $request, TradeTransaction $tradeTransaction): JsonResponse
    {
        $reason = $request->input('reason');
        $tradeTransaction->openDispute($reason);
        $tradeTransaction->save();
        return response()->json(null, 204);
    }

    public function sellerNet(Request $request, TradeTransaction $tradeTransaction): JsonResponse
    {
        $result = $tradeTransaction->sellerNet();
        $tradeTransaction->save();
        return response()->json(['result' => $result]);
    }
}
