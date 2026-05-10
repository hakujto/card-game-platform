<?php

namespace App\Http\Controllers\Api\Marketplace;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Marketplace\Tradelisting;
use App\Models\Players\Player;
use App\Models\Cards\Card;

class TradelistingController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(Tradelisting::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'listing_type' => 'required|string|in:FixedPrice,Auction,TradeOffer|max:20',
            'asking_price' => 'nullable|max:200',
            'auction_start_price' => 'nullable|max:200',
            'auction_current_bid' => 'nullable|max:200',
            'auction_end_time' => 'nullable|date|max:200',
            'foil' => 'required|boolean|max:200',
            'condition' => 'required|string|in:Mint,NearMint,Excellent,Good,Played|max:20',
            'quantity' => 'required|integer|max:200',
            'status' => 'required|string|in:Active,Sold,Expired,Cancelled,Pending|max:20',
            'description' => 'nullable|string|max:200',
            'created_at' => 'required|date|max:200',
            'expires_at' => 'nullable|date|max:200',
            'seller_id' => 'required|exists:players,id',
            'card_id' => 'required|exists:cards,id',
        ]);
        $item = Tradelisting::create($validated);
        return response()->json($item, 201);
    }

    public function show(Tradelisting $tradelisting): JsonResponse
    {
        return response()->json($tradelisting);
    }

    public function update(Request $request, Tradelisting $tradelisting): JsonResponse
    {
        $validated = $request->validate([
            'listing_type' => 'sometimes|nullable|string|max:20',
            'asking_price' => 'sometimes|nullable|max:200',
            'auction_start_price' => 'sometimes|nullable|max:200',
            'auction_current_bid' => 'sometimes|nullable|max:200',
            'auction_end_time' => 'sometimes|nullable|date|max:200',
            'foil' => 'sometimes|nullable|boolean|max:200',
            'condition' => 'sometimes|nullable|string|max:20',
            'quantity' => 'sometimes|nullable|integer|max:200',
            'status' => 'sometimes|nullable|string|max:20',
            'description' => 'sometimes|nullable|string|max:200',
            'created_at' => 'sometimes|nullable|date|max:200',
            'expires_at' => 'sometimes|nullable|date|max:200',
            'seller_id' => 'sometimes|nullable|exists:players,id',
            'card_id' => 'sometimes|nullable|exists:cards,id',
        ]);
        $tradelisting->update($validated);
        return response()->json($tradelisting);
    }

    public function destroy(Tradelisting $tradelisting): JsonResponse
    {
        $tradelisting->delete();
        return response()->json(null, 204);
    }
}
