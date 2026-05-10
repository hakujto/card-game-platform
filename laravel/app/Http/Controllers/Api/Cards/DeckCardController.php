<?php

namespace App\Http\Controllers\Api\Cards;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Cards\DeckCard;
use App\Models\Cards\Deck;
use App\Models\Cards\Card;

class DeckCardController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(DeckCard::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'quantity' => 'required|integer|max:200',
            'is_commander' => 'required|boolean|max:200',
            'deck_id' => 'required|exists:decks,id',
            'card_id' => 'required|exists:cards,id',
        ]);
        $item = DeckCard::create($validated);
        return response()->json($item, 201);
    }

    public function show(DeckCard $deckCard): JsonResponse
    {
        return response()->json($deckCard);
    }

    public function update(Request $request, DeckCard $deckCard): JsonResponse
    {
        $validated = $request->validate([
            'quantity' => 'sometimes|nullable|integer|max:200',
            'is_commander' => 'sometimes|nullable|boolean|max:200',
            'deck_id' => 'sometimes|nullable|exists:decks,id',
            'card_id' => 'sometimes|nullable|exists:cards,id',
        ]);
        $deckCard->update($validated);
        return response()->json($deckCard);
    }

    public function destroy(DeckCard $deckCard): JsonResponse
    {
        $deckCard->delete();
        return response()->json(null, 204);
    }
}
