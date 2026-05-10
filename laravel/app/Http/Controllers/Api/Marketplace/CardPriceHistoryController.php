<?php

namespace App\Http\Controllers\Api\Marketplace;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Marketplace\CardPriceHistory;
use App\Models\Cards\Card;

class CardPriceHistoryController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(CardPriceHistory::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'price_date' => 'required|date|max:200',
            'avg_price' => 'required|max:200',
            'min_price' => 'required|max:200',
            'max_price' => 'required|max:200',
            'volume' => 'required|integer|max:200',
            'foil' => 'required|boolean|max:200',
            'card_id' => 'required|exists:cards,id',
        ]);
        $item = CardPriceHistory::create($validated);
        return response()->json($item, 201);
    }

    public function show(CardPriceHistory $cardPriceHistory): JsonResponse
    {
        return response()->json($cardPriceHistory);
    }

    public function update(Request $request, CardPriceHistory $cardPriceHistory): JsonResponse
    {
        $validated = $request->validate([
            'price_date' => 'sometimes|nullable|date|max:200',
            'avg_price' => 'sometimes|nullable|max:200',
            'min_price' => 'sometimes|nullable|max:200',
            'max_price' => 'sometimes|nullable|max:200',
            'volume' => 'sometimes|nullable|integer|max:200',
            'foil' => 'sometimes|nullable|boolean|max:200',
            'card_id' => 'sometimes|nullable|exists:cards,id',
        ]);
        $cardPriceHistory->update($validated);
        return response()->json($cardPriceHistory);
    }

    public function destroy(CardPriceHistory $cardPriceHistory): JsonResponse
    {
        $cardPriceHistory->delete();
        return response()->json(null, 204);
    }
}
