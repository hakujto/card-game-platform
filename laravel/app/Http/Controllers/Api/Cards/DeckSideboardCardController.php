<?php

namespace App\Http\Controllers\Api\Cards;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Cards\DeckSideboardCard;
use App\Models\Cards\Deck;
use App\Models\Cards\Card;

class DeckSideboardCardController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(DeckSideboardCard::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'quantity' => 'required|integer',
            'deck_id' => 'required|exists:decks,id',
            'card_id' => 'required|exists:cards,id',
        ]);
        $item = DeckSideboardCard::create($validated);
        return response()->json($item, 201);
    }

    public function show(DeckSideboardCard $deckSideboardCard): JsonResponse
    {
        return response()->json($deckSideboardCard);
    }

    public function update(Request $request, DeckSideboardCard $deckSideboardCard): JsonResponse
    {
        $validated = $request->validate([
            'quantity' => 'sometimes|nullable|integer',
            'deck_id' => 'sometimes|nullable|exists:decks,id',
            'card_id' => 'sometimes|nullable|exists:cards,id',
        ]);
        $deckSideboardCard->update($validated);
        return response()->json($deckSideboardCard);
    }

    public function destroy(DeckSideboardCard $deckSideboardCard): JsonResponse
    {
        $deckSideboardCard->delete();
        return response()->json(null, 204);
    }
}
