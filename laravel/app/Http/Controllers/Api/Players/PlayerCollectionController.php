<?php

namespace App\Http\Controllers\Api\Players;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Players\PlayerCollection;
use App\Models\Players\Player;
use App\Models\Cards\Card;

class PlayerCollectionController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(PlayerCollection::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'quantity' => 'required|integer',
            'foil' => 'required|boolean',
            'condition' => 'required|string|in:Mint,NearMint,Excellent,Good,Played|max:20',
            'acquired_at' => 'required|date',
            'acquired_via' => 'required|string|in:Purchase,Trade,TournamentReward,Pack,Craft|max:20',
            'player_id' => 'required|exists:players,id',
            'card_id' => 'required|exists:cards,id',
        ]);
        $item = PlayerCollection::create($validated);
        $item->validateRules();

        return response()->json($item, 201);
    }

    public function show(PlayerCollection $playerCollection): JsonResponse
    {
        return response()->json($playerCollection);
    }

    public function update(Request $request, PlayerCollection $playerCollection): JsonResponse
    {
        $validated = $request->validate([
            'quantity' => 'sometimes|nullable|integer',
            'foil' => 'sometimes|nullable|boolean',
            'condition' => 'sometimes|nullable|string|max:20',
            'acquired_at' => 'sometimes|nullable|date',
            'acquired_via' => 'sometimes|nullable|string|max:20',
            'player_id' => 'sometimes|nullable|exists:players,id',
            'card_id' => 'sometimes|nullable|exists:cards,id',
        ]);
        $playerCollection->update($validated);
        $playerCollection->validateRules();

        return response()->json($playerCollection);
    }

    public function destroy(PlayerCollection $playerCollection): JsonResponse
    {
        $playerCollection->delete();
        return response()->json(null, 204);
    }
    public function add(Request $request, PlayerCollection $playerCollection): JsonResponse
    {
        $quantity = $request->input('quantity');
        $playerCollection->add($quantity);
        $playerCollection->save();
        return response()->json(null, 204);
    }

    public function remove(Request $request, PlayerCollection $playerCollection): JsonResponse
    {
        $quantity = $request->input('quantity');
        $playerCollection->remove($quantity);
        $playerCollection->save();
        return response()->json(null, 204);
    }

    public function estimatedValue(Request $request, PlayerCollection $playerCollection): JsonResponse
    {
        $result = $playerCollection->estimatedValue();
        $playerCollection->save();
        return response()->json(['result' => $result]);
    }
}
