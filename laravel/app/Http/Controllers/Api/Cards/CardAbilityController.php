<?php

namespace App\Http\Controllers\Api\Cards;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Cards\CardAbility;
use App\Models\Cards\Card;

class CardAbilityController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(CardAbility::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'ability_type' => 'required|string|in:Keyword,Activated,Triggered,Static|max:20',
            'keyword' => 'nullable|string|max:100',
            'ability_text' => 'required|string|max:200',
            'timing' => 'nullable|string|in:Any,Sorcery,Instant,Combat|max:20',
            'card_id' => 'required|exists:cards,id',
        ]);
        $item = CardAbility::create($validated);
        try {
            $item->validateImplies();
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }

        return response()->json($item, 201);
    }

    public function show(CardAbility $cardAbility): JsonResponse
    {
        return response()->json($cardAbility);
    }

    public function update(Request $request, CardAbility $cardAbility): JsonResponse
    {
        $validated = $request->validate([
            'ability_type' => 'sometimes|nullable|string|max:20',
            'keyword' => 'sometimes|nullable|string|max:100',
            'ability_text' => 'sometimes|nullable|string|max:200',
            'timing' => 'sometimes|nullable|string|max:20',
            'card_id' => 'sometimes|nullable|exists:cards,id',
        ]);
        $cardAbility->update($validated);
        try {
            $cardAbility->validateImplies();
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }

        return response()->json($cardAbility);
    }

    public function destroy(CardAbility $cardAbility): JsonResponse
    {
        $cardAbility->delete();
        return response()->json(null, 204);
    }
}
