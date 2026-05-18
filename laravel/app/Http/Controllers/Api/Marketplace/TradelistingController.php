<?php

namespace App\Http\Controllers\Api\Marketplace;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Marketplace\TradeListing;
use App\Models\Players\Player;
use App\Models\Cards\Card;

class TradeListingController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(TradeListing::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'listing_type' => 'required|string|in:FixedPrice,Auction,TradeOffer|max:20',
            'asking_price' => 'nullable',
            'auction_start_price' => 'nullable',
            'auction_current_bid' => 'nullable',
            'auction_end_time' => 'nullable|date',
            'foil' => 'required|boolean',
            'condition' => 'required|string|in:Mint,NearMint,Excellent,Good,Played|max:20',
            'quantity' => 'required|integer',
            'status' => 'required|string|in:Active,Sold,Expired,Cancelled,Pending|max:20',
            'description' => 'nullable|string|max:200',
            'created_at' => 'required|date',
            'expires_at' => 'nullable|date',
            'seller_id' => 'required|exists:players,id',
            'card_id' => 'required|exists:cards,id',
        ]);
        $item = TradeListing::create($validated);
        $item->validateRules();
        try {
            $item->validateImplies();
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }

        return response()->json($item, 201);
    }

    public function show(TradeListing $tradeListing): JsonResponse
    {
        return response()->json($tradeListing);
    }

    public function update(Request $request, TradeListing $tradeListing): JsonResponse
    {
        $validated = $request->validate([
            'listing_type' => 'sometimes|nullable|string|max:20',
            'asking_price' => 'sometimes|nullable',
            'auction_start_price' => 'sometimes|nullable',
            'auction_current_bid' => 'sometimes|nullable',
            'auction_end_time' => 'sometimes|nullable|date',
            'foil' => 'sometimes|nullable|boolean',
            'condition' => 'sometimes|nullable|string|max:20',
            'quantity' => 'sometimes|nullable|integer',
            'status' => 'sometimes|nullable|string|max:20',
            'description' => 'sometimes|nullable|string|max:200',
            'created_at' => 'sometimes|nullable|date',
            'expires_at' => 'sometimes|nullable|date',
            'seller_id' => 'sometimes|nullable|exists:players,id',
            'card_id' => 'sometimes|nullable|exists:cards,id',
        ]);
        $tradeListing->update($validated);
        $tradeListing->validateRules();
        try {
            $tradeListing->validateImplies();
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }

        return response()->json($tradeListing);
    }

    public function destroy(TradeListing $tradeListing): JsonResponse
    {
        $tradeListing->delete();
        return response()->json(null, 204);
    }
    public function close(Request $request, TradeListing $tradeListing): JsonResponse
    {
        $tradeListing->close();
        $tradeListing->save();
        return response()->json(null, 204);
    }

    public function extend(Request $request, TradeListing $tradeListing): JsonResponse
    {
        $days = $request->input('days');
        $tradeListing->extend($days);
        $tradeListing->save();
        return response()->json(null, 204);
    }

    public function cancel(Request $request, TradeListing $tradeListing): JsonResponse
    {
        $tradeListing->cancel();
        $tradeListing->save();
        return response()->json(null, 204);
    }

    public function isExpired(Request $request, TradeListing $tradeListing): JsonResponse
    {
        $result = $tradeListing->isExpired();
        $tradeListing->save();
        return response()->json(['result' => $result]);
    }

    public function finalizeAuction(Request $request, TradeListing $tradeListing): JsonResponse
    {
        $tradeListing->finalizeAuction();
        $tradeListing->save();
        return response()->json(null, 204);
    }
}
