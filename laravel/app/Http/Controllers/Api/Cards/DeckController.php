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
            'is_public' => 'required|boolean',
            'is_tournament_legal' => 'required|boolean',
            'archetype' => 'nullable|string|in:Aggro,Control,Midrange,Combo,Prison,Tempo|max:20',
            'wins' => 'required|integer',
            'losses' => 'required|integer',
            'draws' => 'required|integer',
            'created_at' => 'required|date',
            'updated_at' => 'required|date',
            'player_id' => 'required|exists:players,id',
        ]);
        $item = Deck::create($validated);
        $item->validateRules();
        try {
            $item->validateImplies();
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }

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
            'is_public' => 'sometimes|nullable|boolean',
            'is_tournament_legal' => 'sometimes|nullable|boolean',
            'archetype' => 'sometimes|nullable|string|max:20',
            'wins' => 'sometimes|nullable|integer',
            'losses' => 'sometimes|nullable|integer',
            'draws' => 'sometimes|nullable|integer',
            'created_at' => 'sometimes|nullable|date',
            'updated_at' => 'sometimes|nullable|date',
            'player_id' => 'sometimes|nullable|exists:players,id',
        ]);
        $deck->update($validated);
        $deck->validateRules();
        try {
            $deck->validateImplies();
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }

        return response()->json($deck);
    }

    public function destroy(Deck $deck): JsonResponse
    {
        $deck->delete();
        return response()->json(null, 204);
    }
    public function validateSize(Request $request, Deck $deck): JsonResponse
    {
        $result = $deck->validateSize();
        $deck->save();
        return response()->json(['result' => $result]);
    }

    public function addCard(Request $request, Deck $deck): JsonResponse
    {
        $card_id = $request->input('card_id');
        $quantity = $request->input('quantity');
        $deck->addCard($card_id, $quantity);
        $deck->save();
        return response()->json(null, 204);
    }

    public function removeCard(Request $request, Deck $deck): JsonResponse
    {
        $deck->removeCard();
        $deck->save();
        return response()->json(null, 204);
    }

    public function winRate(Request $request, Deck $deck): JsonResponse
    {
        $result = $deck->winRate();
        $deck->save();
        return response()->json(['result' => $result]);
    }

    public function clone(Request $request, Deck $deck): JsonResponse
    {
        $result = $deck->clone();
        $deck->save();
        return response()->json(['result' => $result]);
    }

    public function publish(Request $request, Deck $deck): JsonResponse
    {
        $deck->publish();
        $deck->save();
        return response()->json(null, 204);
    }

    public function unpublish(Request $request, Deck $deck): JsonResponse
    {
        $deck->unpublish();
        $deck->save();
        return response()->json(null, 204);
    }

    public function certifyTournamentLegal(Request $request, Deck $deck): JsonResponse
    {
        $result = $deck->certifyTournamentLegal();
        $deck->save();
        return response()->json(['result' => $result]);
    }
}
