<?php

namespace App\Http\Controllers\Api\Tournaments;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Tournaments\TournamentPrize;
use App\Models\Tournaments\Tournament;

class TournamentPrizeController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(TournamentPrize::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'placement_from' => 'required|integer|max:200',
            'placement_to' => 'required|integer|max:200',
            'prize_type' => 'required|string|in:Currency,Cards,BoosterPacks,Trophy,SeasonPoints,Mixed|max:20',
            'amount' => 'required|max:200',
            'description' => 'nullable|string|max:200',
            'packs_count' => 'nullable|integer|max:200',
            'season_points' => 'required|integer|max:200',
            'tournament_id' => 'required|exists:tournaments,id',
        ]);
        $item = TournamentPrize::create($validated);
        return response()->json($item, 201);
    }

    public function show(TournamentPrize $tournamentPrize): JsonResponse
    {
        return response()->json($tournamentPrize);
    }

    public function update(Request $request, TournamentPrize $tournamentPrize): JsonResponse
    {
        $validated = $request->validate([
            'placement_from' => 'sometimes|nullable|integer|max:200',
            'placement_to' => 'sometimes|nullable|integer|max:200',
            'prize_type' => 'sometimes|nullable|string|max:20',
            'amount' => 'sometimes|nullable|max:200',
            'description' => 'sometimes|nullable|string|max:200',
            'packs_count' => 'sometimes|nullable|integer|max:200',
            'season_points' => 'sometimes|nullable|integer|max:200',
            'tournament_id' => 'sometimes|nullable|exists:tournaments,id',
        ]);
        $tournamentPrize->update($validated);
        return response()->json($tournamentPrize);
    }

    public function destroy(TournamentPrize $tournamentPrize): JsonResponse
    {
        $tournamentPrize->delete();
        return response()->json(null, 204);
    }
}
