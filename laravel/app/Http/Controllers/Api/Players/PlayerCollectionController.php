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
            'quantity' => 'required|integer|max:200',
            'foil' => 'required|boolean|max:200',
            'condition' => 'required|string|in:Mint,NearMint,Excellent,Good,Played|max:20',
            'acquired_at' => 'required|date|max:200',
            'acquired_via' => 'required|string|in:Purchase,Trade,TournamentReward,Pack,Craft|max:20',
            'player_id' => 'required|exists:players,id',
            'card_id' => 'required|exists:cards,id',
        ]);
        $item = PlayerCollection::create($validated);
        return response()->json($item, 201);
    }

    public function show(PlayerCollection $playerCollection): JsonResponse
    {
        return response()->json($playerCollection);
    }

    public function update(Request $request, PlayerCollection $playerCollection): JsonResponse
    {
        $validated = $request->validate([
            'quantity' => 'sometimes|nullable|integer|max:200',
            'foil' => 'sometimes|nullable|boolean|max:200',
            'condition' => 'sometimes|nullable|string|max:20',
            'acquired_at' => 'sometimes|nullable|date|max:200',
            'acquired_via' => 'sometimes|nullable|string|max:20',
            'player_id' => 'sometimes|nullable|exists:players,id',
            'card_id' => 'sometimes|nullable|exists:cards,id',
        ]);
        $playerCollection->update($validated);
        return response()->json($playerCollection);
    }

    public function destroy(PlayerCollection $playerCollection): JsonResponse
    {
        $playerCollection->delete();
        return response()->json(null, 204);
    }
}
