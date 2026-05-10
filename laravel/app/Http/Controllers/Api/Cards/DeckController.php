<?php

namespace App\Http\Controllers\Api\Cards;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Cards\Deck;
use App\Models\Players\Player;

class DeckController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(Deck::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:100',
            'description' => 'nullable|string|max:200',
            'format' => 'required|string|in:Standard,Extended,Legacy,Vintage,Commander,Draft|max:20',
            'is_public' => 'required|boolean|max:200',
            'is_tournament_legal' => 'required|boolean|max:200',
            'archetype' => 'nullable|string|in:Aggro,Control,Midrange,Combo,Prison,Tempo|max:20',
            'wins' => 'required|integer|max:200',
            'losses' => 'required|integer|max:200',
            'created_at' => 'required|date|max:200',
            'updated_at' => 'required|date|max:200',
            'player_id' => 'required|exists:players,id',
        ]);
        $item = Deck::create($validated);
        return response()->json($item, 201);
    }

    public function show(Deck $deck): JsonResponse
    {
        return response()->json($deck);
    }

    public function update(Request $request, Deck $deck): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'sometimes|nullable|string|max:100',
            'description' => 'sometimes|nullable|string|max:200',
            'format' => 'sometimes|nullable|string|max:20',
            'is_public' => 'sometimes|nullable|boolean|max:200',
            'is_tournament_legal' => 'sometimes|nullable|boolean|max:200',
            'archetype' => 'sometimes|nullable|string|max:20',
            'wins' => 'sometimes|nullable|integer|max:200',
            'losses' => 'sometimes|nullable|integer|max:200',
            'created_at' => 'sometimes|nullable|date|max:200',
            'updated_at' => 'sometimes|nullable|date|max:200',
            'player_id' => 'sometimes|nullable|exists:players,id',
        ]);
        $deck->update($validated);
        return response()->json($deck);
    }

    public function destroy(Deck $deck): JsonResponse
    {
        $deck->delete();
        return response()->json(null, 204);
    }
}
