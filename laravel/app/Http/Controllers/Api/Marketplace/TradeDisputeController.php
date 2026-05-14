<?php

namespace App\Http\Controllers\Api\Marketplace;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Marketplace\TradeDispute;
use App\Models\Marketplace\TradeTransaction;
use App\Models\Players\Player;

class TradeDisputeController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(TradeDispute::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'reason' => 'required|string|in:ItemNotReceived,ItemNotAsDescribed,FraudSuspected,Other|max:20',
            'description' => 'required|string|max:200',
            'status' => 'required|string|in:Open,UnderReview,Resolved,Escalated|max:20',
            'resolution' => 'nullable|string|max:200',
            'opened_at' => 'required|date',
            'resolved_at' => 'nullable|date',
            'transaction_id' => 'required|exists:trade_transactions,id',
            'opened_by_id' => 'required|exists:players,id',
            'resolved_by_id' => 'nullable|exists:players,id',
        ]);
        $item = TradeDispute::create($validated);
        try {
            $item->validateImplies();
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }

        return response()->json($item, 201);
    }

    public function show(TradeDispute $tradeDispute): JsonResponse
    {
        return response()->json($tradeDispute);
    }

    public function update(Request $request, TradeDispute $tradeDispute): JsonResponse
    {
        $validated = $request->validate([
            'reason' => 'sometimes|nullable|string|max:20',
            'description' => 'sometimes|nullable|string|max:200',
            'status' => 'sometimes|nullable|string|max:20',
            'resolution' => 'sometimes|nullable|string|max:200',
            'opened_at' => 'sometimes|nullable|date',
            'resolved_at' => 'sometimes|nullable|date',
            'transaction_id' => 'sometimes|nullable|exists:trade_transactions,id',
            'opened_by_id' => 'sometimes|nullable|exists:players,id',
            'resolved_by_id' => 'sometimes|nullable|exists:players,id',
        ]);
        $tradeDispute->update($validated);
        try {
            $tradeDispute->validateImplies();
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }

        return response()->json($tradeDispute);
    }

    public function destroy(TradeDispute $tradeDispute): JsonResponse
    {
        $tradeDispute->delete();
        return response()->json(null, 204);
    }
    public function escalate(Request $request, TradeDispute $tradeDispute): JsonResponse
    {
        $tradeDispute->escalate();
        $tradeDispute->save();
        return response()->json(null, 204);
    }

    public function resolve(Request $request, TradeDispute $tradeDispute): JsonResponse
    {
        $resolution_text = $request->input('resolution_text');
        $tradeDispute->resolve($resolution_text);
        $tradeDispute->save();
        return response()->json(null, 204);
    }

    public function review(Request $request, TradeDispute $tradeDispute): JsonResponse
    {
        $tradeDispute->review();
        $tradeDispute->save();
        return response()->json(null, 204);
    }
}
