<?php

namespace App\Http\Controllers\Api\Tournaments;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Tournaments\AwardedPrize;
use App\Models\Tournaments\TournamentPrize;
use App\Models\Players\Player;

class AwardedPrizeController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(AwardedPrize::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'final_placement' => 'required|integer|max:200',
            'awarded_at' => 'required|date|max:200',
            'claimed' => 'required|boolean|max:200',
            'claimed_at' => 'nullable|date|max:200',
            'prize_id' => 'required|exists:tournament_prizes,id',
            'player_id' => 'required|exists:players,id',
        ]);
        $item = AwardedPrize::create($validated);
        return response()->json($item, 201);
    }

    public function show(AwardedPrize $awardedPrize): JsonResponse
    {
        return response()->json($awardedPrize);
    }

    public function update(Request $request, AwardedPrize $awardedPrize): JsonResponse
    {
        $validated = $request->validate([
            'final_placement' => 'sometimes|nullable|integer|max:200',
            'awarded_at' => 'sometimes|nullable|date|max:200',
            'claimed' => 'sometimes|nullable|boolean|max:200',
            'claimed_at' => 'sometimes|nullable|date|max:200',
            'prize_id' => 'sometimes|nullable|exists:tournament_prizes,id',
            'player_id' => 'sometimes|nullable|exists:players,id',
        ]);
        $awardedPrize->update($validated);
        return response()->json($awardedPrize);
    }

    public function destroy(AwardedPrize $awardedPrize): JsonResponse
    {
        $awardedPrize->delete();
        return response()->json(null, 204);
    }
}
