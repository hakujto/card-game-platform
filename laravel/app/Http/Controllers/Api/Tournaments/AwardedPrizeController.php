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
            'final_placement' => 'required|integer',
            'awarded_at' => 'required|date',
            'claimed' => 'required|boolean',
            'claimed_at' => 'nullable|date',
            'prize_id' => 'required|exists:tournament_prizes,id',
            'player_id' => 'required|exists:players,id',
        ]);
        $item = AwardedPrize::create($validated);
        $item->validateRules();
        try {
            $item->validateImplies();
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }

        return response()->json($item, 201);
    }

    public function show(AwardedPrize $awardedPrize): JsonResponse
    {
        return response()->json($awardedPrize);
    }

    public function update(Request $request, AwardedPrize $awardedPrize): JsonResponse
    {
        $validated = $request->validate([
            'final_placement' => 'sometimes|nullable|integer',
            'awarded_at' => 'sometimes|nullable|date',
            'claimed' => 'sometimes|nullable|boolean',
            'claimed_at' => 'sometimes|nullable|date',
            'prize_id' => 'sometimes|nullable|exists:tournament_prizes,id',
            'player_id' => 'sometimes|nullable|exists:players,id',
        ]);
        $awardedPrize->update($validated);
        $awardedPrize->validateRules();
        try {
            $awardedPrize->validateImplies();
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }

        return response()->json($awardedPrize);
    }

    public function destroy(AwardedPrize $awardedPrize): JsonResponse
    {
        $awardedPrize->delete();
        return response()->json(null, 204);
    }
}
