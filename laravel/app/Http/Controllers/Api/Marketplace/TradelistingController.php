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

    public function index(Request $request): JsonResponse
    {
        $q = $request->query('q');
        if ($q) {
            $items = TradeListing::query()
                ->where('description', 'like', '%' . $q . '%')->get();
        } else {
            $items = TradeListing::all();
        }
        return response()->json($items);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'public_id' => 'required|unique:trade_listings,public_id',
            'status' => 'required|string|in:Active,Sold,Expired,Cancelled,Pending|max:20',
            'listing_type' => 'required|string|in:FixedPrice,Auction,TradeOffer|max:20',
            'asking_price' => 'required_if:listing_type,FixedPrice|nullable',
            'auction_start_price' => 'nullable',
            'auction_current_bid' => 'nullable',
            'auction_end_time' => 'nullable|date',
            'foil' => 'required|boolean',
            'condition' => 'required|string|in:Mint,NearMint,Excellent,Good,Played|max:20',
            'quantity' => 'required|integer',
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
            'public_id' => 'sometimes|nullable',
            'listing_type' => 'sometimes|nullable|string|max:20',
            'asking_price' => 'sometimes|nullable',
            'auction_start_price' => 'sometimes|nullable',
            'auction_current_bid' => 'sometimes|nullable',
            'auction_end_time' => 'sometimes|nullable|date',
            'foil' => 'sometimes|nullable|boolean',
            'condition' => 'sometimes|nullable|string|max:20',
            'quantity' => 'sometimes|nullable|integer',
            'description' => 'sometimes|nullable|string|max:200',
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
        if (!($tradeListing->status === 'Active')) {
            return response()->json(['error' => 'Guard condition not met for cancel'], 422);
        }
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
        if (!in_array(auth()->user()?->role, ['admin', 'seller'], true)) {
            return response()->json(['error' => 'Insufficient role for finalize_auction'], 403);
        }
        $tradeListing->finalizeAuction();
        $tradeListing->save();
        return response()->json(null, 204);
    }
    public function transitionPendingToActive(TradeListing $tradeListing): JsonResponse
    {
        if (!in_array(auth()->user()?->role, ['Seller'], true)) {
            return response()->json(['error' => 'Insufficient role for transition Pending -> Active'], 403);
        }
        try {
            $tradeListing->assertTransition('Active');
        } catch (\InvalidArgumentException $e) {
            return response()->json(['error' => $e->getMessage()], 409);
        }
        try {
            if ($tradeListing->quantity === null) {
                throw new \RuntimeException('quantity is required for Pending -> Active');
            }
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }
        $tradeListing->status = 'Active';
        $tradeListing->save();
        return response()->json($tradeListing);
    }

    public function transitionActiveToSold(TradeListing $tradeListing): JsonResponse
    {
        try {
            $tradeListing->assertTransition('Sold');
        } catch (\InvalidArgumentException $e) {
            return response()->json(['error' => $e->getMessage()], 409);
        }
        $tradeListing->status = 'Sold';
        $tradeListing->finalizeAuction(); // @after
        $tradeListing->save();
        return response()->json($tradeListing);
    }

    public function transitionActiveToExpired(TradeListing $tradeListing): JsonResponse
    {
        try {
            $tradeListing->assertTransition('Expired');
        } catch (\InvalidArgumentException $e) {
            return response()->json(['error' => $e->getMessage()], 409);
        }
        $tradeListing->status = 'Expired';
        $tradeListing->close(); // @after
        $tradeListing->save();
        return response()->json($tradeListing);
    }

    public function transitionActiveToCancelled(TradeListing $tradeListing): JsonResponse
    {
        if (!in_array(auth()->user()?->role, ['Seller', 'Admin'], true)) {
            return response()->json(['error' => 'Insufficient role for transition Active -> Cancelled'], 403);
        }
        try {
            $tradeListing->assertTransition('Cancelled');
        } catch (\InvalidArgumentException $e) {
            return response()->json(['error' => $e->getMessage()], 409);
        }
        $tradeListing->status = 'Cancelled';
        $tradeListing->cancel(); // @after
        $tradeListing->save();
        return response()->json($tradeListing);
    }

    public function transitionSoldToActive(TradeListing $tradeListing): JsonResponse
    {
        return response()->json(['error' => 'Transition Sold -> Active is not allowed'], 409);
    }

    public function transitionExpiredToActive(TradeListing $tradeListing): JsonResponse
    {
        return response()->json(['error' => 'Transition Expired -> Active is not allowed'], 409);
    }
}
