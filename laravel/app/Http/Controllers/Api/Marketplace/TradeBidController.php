<?php

namespace App\Http\Controllers\Api\Marketplace;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Marketplace\TradeBid;
use App\Models\Marketplace\TradeListing;
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
            'listing_id' => 'required|exists:trade_listings,id',
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

    public function outbidBy(Request $request, TradeBid $tradeBid): JsonResponse
    {
        $result = $tradeBid->outbidBy();
        $tradeBid->save();
        return response()->json(['result' => $result]);
    }

    public function retract(Request $request, TradeBid $tradeBid): JsonResponse
    {
        $tradeBid->retract();
        $tradeBid->save();
        return response()->json(null, 204);
    }
}
