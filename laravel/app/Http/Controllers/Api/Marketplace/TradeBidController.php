<?php

namespace App\Http\Controllers\Api\Marketplace;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Marketplace\TradeBid;
use App\Models\Marketplace\Tradelisting;
use App\Models\Players\Player;

class TradeBidController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(TradeBid::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'amount' => 'required',
            'placed_at' => 'required|date',
            'is_winning' => 'required|boolean',
            'listing_id' => 'required|exists:tradelistings,id',
            'bidder_id' => 'required|exists:players,id',
        ]);
        $item = TradeBid::create($validated);
        $item->validateRules();

        return response()->json($item, 201);
    }

    public function show(TradeBid $tradeBid): JsonResponse
    {
        return response()->json($tradeBid);
    }

    public function update(Request $request, TradeBid $tradeBid): JsonResponse
    {
        $validated = $request->validate([
            'amount' => 'sometimes|nullable',
            'placed_at' => 'sometimes|nullable|date',
            'is_winning' => 'sometimes|nullable|boolean',
            'listing_id' => 'sometimes|nullable|exists:tradelistings,id',
            'bidder_id' => 'sometimes|nullable|exists:players,id',
        ]);
        $tradeBid->update($validated);
        $tradeBid->validateRules();

        return response()->json($tradeBid);
    }

    public function destroy(TradeBid $tradeBid): JsonResponse
    {
        $tradeBid->delete();
        return response()->json(null, 204);
    }
}
