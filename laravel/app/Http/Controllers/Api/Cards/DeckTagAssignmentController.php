<?php

namespace App\Http\Controllers\Api\Cards;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Cards\DeckTagAssignment;
use App\Models\Cards\Deck;
use App\Models\Cards\DeckTag;

class DeckTagAssignmentController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(DeckTagAssignment::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'deck_id' => 'required|exists:decks,id',
            'tag_id' => 'required|exists:deck_tags,id',
        ]);
        $item = DeckTagAssignment::create($validated);
        return response()->json($item, 201);
    }

    public function show(DeckTagAssignment $deckTagAssignment): JsonResponse
    {
        return response()->json($deckTagAssignment);
    }

    public function update(Request $request, DeckTagAssignment $deckTagAssignment): JsonResponse
    {
        $validated = $request->validate([
            'deck_id' => 'sometimes|nullable|exists:decks,id',
            'tag_id' => 'sometimes|nullable|exists:deck_tags,id',
        ]);
        $deckTagAssignment->update($validated);
        return response()->json($deckTagAssignment);
    }

    public function destroy(DeckTagAssignment $deckTagAssignment): JsonResponse
    {
        $deckTagAssignment->delete();
        return response()->json(null, 204);
    }
}
