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
            'wins' => 'required|integer|max:200',
            'losses' => 'required|integer|max:200',
            'draws' => 'required|integer|max:200',
            'tournament_wins' => 'required|integer|max:200',
            'highest_rank' => 'nullable|string|in:Bronze,Silver,Gold,Platinum,Diamond,Master,Grandmaster|max:20',
            'season_points' => 'required|integer|max:200',
            'player_id' => 'required|exists:players,id',
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
            'wins' => 'sometimes|nullable|integer|max:200',
            'losses' => 'sometimes|nullable|integer|max:200',
            'draws' => 'sometimes|nullable|integer|max:200',
            'tournament_wins' => 'sometimes|nullable|integer|max:200',
            'highest_rank' => 'sometimes|nullable|string|max:20',
            'season_points' => 'sometimes|nullable|integer|max:200',
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
