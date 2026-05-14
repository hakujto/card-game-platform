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
            'price_date' => 'required|date',
            'avg_price' => 'required',
            'min_price' => 'required',
            'max_price' => 'required',
            'volume' => 'required|integer',
            'foil' => 'required|boolean',
            'card_id' => 'required|exists:cards,id',
        ]);
        $item = CardPriceHistory::create($validated);
        $item->validateRules();

        return response()->json($item, 201);
    }

    public function show(CardPriceHistory $cardPriceHistory): JsonResponse
    {
        return response()->json($cardPriceHistory);
    }

    public function update(Request $request, CardPriceHistory $cardPriceHistory): JsonResponse
    {
        $validated = $request->validate([
            'price_date' => 'sometimes|nullable|date',
            'avg_price' => 'sometimes|nullable',
            'min_price' => 'sometimes|nullable',
            'max_price' => 'sometimes|nullable',
            'volume' => 'sometimes|nullable|integer',
            'foil' => 'sometimes|nullable|boolean',
            'card_id' => 'sometimes|nullable|exists:cards,id',
        ]);
        $cardPriceHistory->update($validated);
        $cardPriceHistory->validateRules();

        return response()->json($cardPriceHistory);
    }

    public function destroy(CardPriceHistory $cardPriceHistory): JsonResponse
    {
        $cardPriceHistory->delete();
        return response()->json(null, 204);
    }
}
