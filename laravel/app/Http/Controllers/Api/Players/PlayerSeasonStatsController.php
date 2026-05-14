<?php

namespace App\Http\Controllers\Api\Players;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Players\PlayerSeasonStats;
use App\Models\Players\Player;
use App\Models\Tournaments\Season;

class PlayerSeasonStatsController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(PlayerSeasonStats::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'wins' => 'required|integer',
            'losses' => 'required|integer',
            'draws' => 'required|integer',
            'tournament_wins' => 'required|integer',
            'highest_rank' => 'nullable|string|in:Bronze,Silver,Gold,Platinum,Diamond,Master,Grandmaster|max:20',
            'season_points' => 'required|integer',
            'player_id' => 'nullable|exists:players,id',
            'season_id' => 'required|exists:seasons,id',
        ]);
        $item = PlayerSeasonStats::create($validated);
        return response()->json($item, 201);
    }

    public function show(PlayerSeasonStats $playerSeasonStats): JsonResponse
    {
        return response()->json($playerSeasonStats);
    }

    public function update(Request $request, PlayerSeasonStats $playerSeasonStats): JsonResponse
    {
        $validated = $request->validate([
            'wins' => 'sometimes|nullable|integer',
            'losses' => 'sometimes|nullable|integer',
            'draws' => 'sometimes|nullable|integer',
            'tournament_wins' => 'sometimes|nullable|integer',
            'highest_rank' => 'sometimes|nullable|string|max:20',
            'season_points' => 'sometimes|nullable|integer',
            'player_id' => 'sometimes|nullable|exists:players,id',
            'season_id' => 'sometimes|nullable|exists:seasons,id',
        ]);
        $playerSeasonStats->update($validated);
        return response()->json($playerSeasonStats);
    }

    public function destroy(PlayerSeasonStats $playerSeasonStats): JsonResponse
    {
        $playerSeasonStats->delete();
        return response()->json(null, 204);
    }
}
